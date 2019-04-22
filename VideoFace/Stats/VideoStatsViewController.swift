//
//  VideoStatsViewController.swift
//  VideoFace
//
//  Created by Marco Rossi on 04/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Charts
import RxDataSources
import Hero
import StatefulViewController
import Action

import MaterialComponents.MaterialAppBar
import MaterialComponents.MaterialButtons
import MaterialComponents.MDCCard
import MaterialComponents.MDCButton
import MaterialComponents.MaterialIcons_ic_arrow_back

class ChartsFormatterPercent: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // y-value percent
        return "\(Int(value*100))%"
    }
}

class VideoStatsViewController: UIViewController, BindableType, StoryboardInstantiatable {
    
    static var StoryboardName = "Stats"
    
    // MARK: IBOutlets
    @IBOutlet weak var playerView: WKYTPlayerView!
    @IBOutlet weak var statView: UIView!
    
    // MARK: Private
    private let appBar = MDCAppBar()
    private var disposeBag = DisposeBag()
    private var samples: [EmotionSample]?
    private var summary: SummaryData?
    private var currentTime: BehaviorSubject<Float> = BehaviorSubject(value: 0)
    private var trigger: PublishSubject<Void> = PublishSubject()
    
    private var playerState: WKYTPlayerState = .unknown
    private var videoPaused = false
    
    // MARK: ViewModel
    var viewModel: VideoStatsViewModel!
    
    lazy var emotionGroupModel: EmotionGroupViewModel = {
        let items = [
            .happiness,
            .surprise,
            .sadness,
            .fear,
            .disgust,
            .anger
            ].map { EmotionStatItem(emotion: $0) }
        let viewModel = EmotionGroupViewModel(items: items)
        viewModel.didToggleSelection = { [weak self] items in
            let emotions = items.map { $0.emotion }
            self?.updateChartData(emotions)
        }
        return viewModel
    }()
    
    lazy var emotionGroupView: EmotionGroupView = {
        let group = EmotionGroupView.instantiateFromNib()
        return group
    }()
    
    lazy var chartView: LineChartView = {
        var chartView = LineChartView()
        
        chartView.legend.enabled = false
        chartView.chartDescription = nil
        
        chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.granularity = 5.0
        chartView.xAxis.yOffset = 8.0
        chartView.xAxis.labelTextColor = UIColor.black
        chartView.xAxis.labelFont = UIFont(name: "Raleway-Bold", size: 12)!
        
        chartView.rightAxis.enabled = false
        
        chartView.scaleYEnabled = false
        chartView.scaleXEnabled = false
        chartView.dragEnabled = false
        
        chartView.leftAxis.labelCount = 5
        chartView.leftAxis.xOffset = 8.0
        chartView.leftAxis.axisMinimum = -0.01
        chartView.leftAxis.axisMaximum = 1.01
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawTopYLabelEntryEnabled = true
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.labelTextColor = UIColor.black
        chartView.leftAxis.labelFont = UIFont(name: "Raleway-Bold", size: 12)!
        chartView.leftAxis.valueFormatter = ChartsFormatterPercent()
        
        return chartView
    }()
    
    lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        statView.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(statView)
        }
        
        return scrollView
    }()
    
    lazy var topView: TopView = {
        var topView = TopView.instantiateFromNib()
        return topView
    }()
    
    lazy var summaryView: SummaryView = {
       var summaryView = SummaryView.instantiateFromNib()
        return summaryView
    }()
    
    lazy var dismissAction: CocoaAction = {
        CocoaAction { [weak self] _ in
            return SceneCoordinator.shared.pop(animated: true)
        }
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    deinit {
        print("deinit Stats VC")
    }
    
    func setup() {
        addChildViewController(appBar.headerViewController)
        appBar.headerViewController.headerView.backgroundColor = .clear
        appBar.navigationBar.tintColor = .white
    }
    
    var panGR: UIPanGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup placeholder views
        loadingView = LoadingView(frame: statView.bounds)
        loadingView?.backgroundColor = UIColor.groupTableViewBackground
        
        emptyView = NoDataView.instantiateFromNib()
        let noConnectionView = NoConnectionView.instantiateFromNib()
        noConnectionView.tapGestureRecognizer.addTarget(self, action:#selector(retry))
        errorView = noConnectionView
        
        appBar.addSubviewsToParent()
        
        let backButtonItem = UIBarButtonItem(title:"",
                                             style:.plain,
                                             target:self,
                                             action:#selector(dismissDetails))
        let backImage = UIImage(named:"Back")
        backButtonItem.image = backImage
        appBar.navigationBar.leftBarButtonItem = backButtonItem
        
        let shareButtonItem = UIBarButtonItem(title:"",
                                             style:.plain,
                                             target:self,
                                             action:#selector(onShare))
        let shareImage = UIImage(named:"share")
        shareButtonItem.image = shareImage
        appBar.navigationBar.rightBarButtonItem = shareButtonItem
        
        playerView.delegate = self
        
        panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
//        view.addGestureRecognizer(panGR)
        panGR.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if videoPaused {
            videoPaused = false
            playerView.playVideo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if playerState == .playing {
            self.videoPaused = true
            self.playerView.pauseVideo()
        }
    }
    
    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        // calculate the progress based on how far the user moved
        let translation = panGR.translation(in: nil)
        var translationY = translation.y
        let progress = (translationY / 2) / view.bounds.height
        
        switch panGR.state {
        case .began:
            // begin the transition as normal
            self.dismissAction.execute(())
        case .changed:
            if translationY < 0 {
                translationY = 0
            }
            Hero.shared.update(progress)
            let currentPos = CGPoint(x: 0 , y: translationY)
            Hero.shared.apply(modifiers: [.translate(currentPos)], to: view)
            
        default:
            // end or cancel the transition based on the progress and user's touch velocity
            if progress + panGR.velocity(in: nil).y / view.bounds.height > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }
    
    // MARK: BindableType
    func bindViewModel() {
        assert(viewModel != nil)
        
        self.startLoading()
        setupInitialViewState()
        
        let viewWillAppear = rx.sentMessage(#selector(VideoStatsViewController.viewWillAppear(_:)))
            .mapToVoid()
            .catchErrorJustComplete()

        let input = VideoStatsViewModel.Input(trigger: trigger)
        let output = viewModel.transform(input: input)
        
        output.data
            .subscribe(onNext: { [weak self] data in
                self?.samples = data.samples
                self?.summary = data.summary
                self?.showStats()
            })
            .disposed(by: disposeBag)

        var errorBinding: Binder<Error> {
            return Binder(self, binding: { (vc, error) in
                print(error)
                vc.endLoading(error: error)
            })
        }

        output.error
            .drive(errorBinding)
            .disposed(by: disposeBag)

        var loadingBinding: Binder<Bool> {
            return Binder(self, binding: { (vc, loading) in
                if loading {
                    vc.startLoading()
                }
            })
        }

        output.fetching
            .drive(loadingBinding)
            .disposed(by: disposeBag)

        currentTime
            .throttle(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] time in
                self?.timeChanged(time)
            }).disposed(by: disposeBag)
        
        self.loadVideo()
        self.trigger.onNext(())
    }
    
    @objc func retry() {
        self.trigger.onNext(())
    }
    
    func showData() {
        let container = MDCCard()
        container.cornerRadius = 10
        container.backgroundColor = UIColor.white
        container.isInteractable = false
        container.clipsToBounds = true
        scrollView.addSubview(container)
        
        container.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.top).inset(10)
            make.left.right.equalTo(view).inset(10)
            make.height.equalTo(statView.bounds.height - 20)
        }
        
        let container2 = MDCCard()
        container2.cornerRadius = 10
        container2.isInteractable = false
        container2.clipsToBounds = true
        
        scrollView.addSubview(container2)
        container2.snp.makeConstraints { (make) in
            make.top.equalTo(container.snp.bottom).inset(-10)
            make.left.right.equalTo(view).inset(10)
            make.height.equalTo(270)
            make.bottom.equalTo(scrollView.snp.bottom).inset(10)
        }
        
        //Summary View
        container2.addSubview(summaryView)
        summaryView.snp.makeConstraints { (make) in
            make.top.equalTo(container2).inset(8)
            make.left.right.equalTo(container2).inset(15)
            make.bottom.equalTo(container2).inset(8)
        }
        summaryView.setData(self.summary!)
        
        //Emotion View
        container.addSubview(emotionGroupView)
        emotionGroupView.snp.makeConstraints { (make) in
            make.left.right.equalTo(container).inset(15)
            make.bottom.equalTo(container).inset(8)
        }
        
        let first = (self.samples?.first)!
        emotionGroupModel.setStats(first.stats)
        emotionGroupView.bind(to: emotionGroupModel)
        
        //Divider Bottom
        let dividerBottom = UIView()
        dividerBottom.backgroundColor = UIColor(hexString: "#f0f2f6")
        container.addSubview(dividerBottom)
        dividerBottom.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.left.right.equalTo(container).inset(15)
            make.bottom.equalTo(emotionGroupView.snp.top).inset(-12)
        }
        
        //Top View
        container.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(container.snp.top).inset(12)
            make.left.right.equalTo(container).inset(15)
        }
        self.topView.setFaces(faces: first.faces)
        
        //Divider Top
        let dividerTop = UIView()
        dividerTop.backgroundColor = UIColor(hexString: "#f0f2f6")
        container.addSubview(dividerTop)
        dividerTop.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.left.right.equalTo(container).inset(15)
            make.top.equalTo(topView.snp.bottom).inset(-12)
        }
        
        //Chart View
        container.addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.top.equalTo(dividerTop.snp.bottom).inset(-12)
            make.left.right.equalTo(container).inset(8)
            make.bottom.equalTo(dividerBottom.snp.top).inset(-12)
        }
        
        let emotions = emotionGroupModel.enabledItems.map { $0.emotion }
        updateChartData(emotions)
    }
    
    func createSubDatasets(emotion: Emotion, xVals: [Double], yVals: [Double]) -> [LineChartDataSet] {
        let values = zip(xVals, yVals).map { (x: $0, y: $1) }
        let entries = values.map { ChartDataEntry(x: $0.x, y: $0.y) }
        
        var datasets = [LineChartDataSet]()
        let slicedEntries = entries.sliced(where: { ($1.x - $0.x) > 1 })
        for slice in slicedEntries {
            if (entries.isEmpty == false) {
                let dataset = LineChartDataSet(entries: Array(slice), label: "")
                dataset.lineWidth = 3.0
                dataset.setColor(emotion.color)
                dataset.cubicIntensity = 0.05
                dataset.mode = LineChartDataSet.Mode.cubicBezier
                dataset.circleRadius = 4.0
                dataset.circleHoleRadius = 1.5
                dataset.drawCirclesEnabled = false
                dataset.drawValuesEnabled = false
                datasets.append(dataset)
            }
        }
        
        return datasets
    }
    
    func updateChartData(_ emotions: [Emotion]) {
        guard let stats = self.samples else {
            return
        }
        var datasetsSamples = [Emotion:[Double]]()
        var xValues = [Double]()
        
        for (_, sample) in stats.enumerated() {
            for stat in sample.stats {
                if datasetsSamples[stat.emotion] == nil {
                    datasetsSamples[stat.emotion] = [Double]()
                }
                datasetsSamples[stat.emotion]?.append(stat.value!)
            }
            xValues.append(sample.time)
        }
        
        var datasets = [LineChartDataSet]()
        
        for sample in datasetsSamples {
            let emotion = sample.key
            if emotions.contains(emotion) {
                let subDatasets = createSubDatasets(emotion: sample.key, xVals: xValues, yVals: sample.value)
                datasets.append(contentsOf: subDatasets)
            }
        }
        
        let data = LineChartData(dataSets: datasets)
        chartView.data = data
        chartView.setVisibleXRange(minXRange: 0.0, maxXRange: 12)
    }
    
    func showStats() {
        guard let stats = self.samples, stats.count > 0 else {
            self.endLoading()
            return
        }

        showData()
        
        self.endLoading()
    }
    
    func timeChanged(_ time: Float) {
        let currentTime = Double(roundf(time))
        
        let statSample = samples?.first(where: { sample in sample.time == currentTime }) ?? EmotionSample(time: currentTime, faces: 0, emotions: [:])
        emotionGroupModel.setStats(statSample.stats)
        self.topView.setFaces(faces: statSample.faces)
        
        let moveToTime = currentTime - 6
       
        chartView.xAxis.removeAllLimitLines()
        let line = ChartLimitLine()
        line.limit = currentTime
        line.lineColor = UIColor(hexString: "#CACACA")
        chartView.xAxis.addLimitLine(line)
        
        chartView.moveViewTo(xValue: moveToTime, yValue: 0.0, axis: .left)
    }
    
    func loadVideo() {
        let playerVars = [
            "playsinline": "1",
            "controls": "1",
            "showinfo": "0",
            "autohide": "1",
            "modestbranding": "1",
            "rel": "0",
            "fs": "0"
        ]
        let videoID = viewModel.video.uid
        playerView.load(withVideoId: videoID, playerVars: playerVars)
    }
    
    @objc func dismissDetails() {
//        self.dismissAction.execute(())
        viewModel = nil
        SceneCoordinator.shared.pop(animated: true)
    }
    
    @objc func onShare() {
        let video = viewModel.video
        shareVideo(video)
    }
    
    func shareVideo(_ video: Video, callback: UIActivityViewControllerCompletionWithItemsHandler? = nil) {
        let link = NSURL(string: App.trackingPageBaseURL + video.uid)!
        let activityViewController = UIActivityViewController(activityItems: [link, ActionExtensionBlockerItem()] , applicationActivities: nil)
        activityViewController.completionWithItemsHandler = callback
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension VideoStatsViewController: StatefulViewController {
    var backingView: UIView {
        return statView
    }
    
    func hasContent() -> Bool {
        guard let stats = samples, stats.count > 0 else {
            return false
        }
        return true
    }
    
    func handleErrorWhenContentAvailable(_ error: Error) {
        
    }
}

extension VideoStatsViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == panGR {
            let point = touch.location(in: playerView)
            let isInsidePlayer = playerView.bounds.contains(point)
            return isInsidePlayer && point.y < (playerView.bounds.height - 50)
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
}

extension VideoStatsViewController: WKYTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        playerView.playVideo()
    }
    
    
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        
    }
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: WKYTPlayerView) -> UIColor {
        return UIColor.clear
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        self.playerState = state
    }
    
    func playerView(_ playerView: WKYTPlayerView, didPlayTime playTime: Float) {
        currentTime.onNext(playTime)
    }
}
