//
//  VideosViewController.swift
//  VideoFace
//
//  Created by Marco Rossi on 25/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit
import StoreKit

import MGSwipeTableCell
import RxSwift
import RxCocoa
import Action
import Presentr

import StatefulViewController

import RxRealmDataSources
import RxRealm
import RealmSwift

import MaterialComponents.MDCAppBarNavigationController
import MaterialComponents.MDCAppBarViewController

class VideosViewController: UIViewController, BindableType {
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: Private
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewRealmDataSource<RMVideo>!
    private var refreshControl: UIRefreshControl!
    private var addButton: UIBarButtonItem!
    private var infoButton: UIBarButtonItem!
    
    // MARK: ViewModel
    var viewModel: VideosViewModel!
    
    var hasVideos = false
    
    lazy var goToStatsAction: Action<Video, Void> = {
        Action<Video, Void> { video in
            let statsVM = VideoStatsViewModel(video: video)
            return SceneCoordinator.shared.transition(to: Scene.videoStats(statsVM))
        }
    }()
    
    let customPresenter: Presentr = {
        let width = ModalSize.default
        let height = ModalSize.custom(size: 350)
        let center = ModalCenterPosition.center
        let customType = PresentationType.custom(width: width, height: height, center: center)
        
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = nil
        customPresenter.dismissTransitionType = nil
        customPresenter.dismissAnimated = true
        customPresenter.roundCorners = true
        customPresenter.dismissOnSwipe = true
        return customPresenter
    }()
    
    var navBar: MDCNavigationBar? {
        if let navVC = self.navigationController as? MDCAppBarNavigationController,
            let appBarVC = navVC.appBarViewController(for: self) {
                return appBarVC.navigationBar
        }
        return nil
    }
    
    var infoButtonItem: UIBarButtonItem {
        let infoImage = MDCIcons.imageFor_ic_info()?.withRenderingMode(.alwaysTemplate)
        return  UIBarButtonItem(image: infoImage,
                                       style: .plain,
                                       target: self,
                                       action: #selector(showNoVideos))
    }
    
//    var selectedVideo: PublishSubject<IndexPath> = PublishSubject()
    var deletedVideo: PublishSubject<IndexPath> = PublishSubject()
    var syncVideos: PublishSubject<Void> = PublishSubject()
//    var trigger: PublishSubject<Void> = PublishSubject()
    
//    let appBarViewController = MDCAppBarViewController()
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        
//        self.addChildViewController(appBarViewController)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    lazy var titleView: UIView = {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        return titleLabel
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup placeholder views
        loadingView = LoadingView(frame: tableView.bounds)
        let noVideosView = NoVideosView.instantiateFromNib()
        noVideosView.onTap = {
            self.openYouTube()
        }
        emptyView = noVideosView
        
        configureRefreshControl()
        configureTableView()
        
//        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        
//        view.addSubview(appBarViewController.view)
//        appBarViewController.didMove(toParentViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isBeingPresented || isMovingToParentViewController {
            // This is the first time this instance of the view controller will appear
            setupInitialViewState()
            
            //Setup app bar
            if let navVC = self.navigationController as? MDCAppBarNavigationController,
                let appBarVC = navVC.appBarViewController(for: self) {
                appBarVC.headerView.backgroundColor = UIColor(hexString: "#272727")
                
                let navBar = appBarVC.navigationBar
                navBar.tintColor = UIColor.white
                let titleView = TitleView.instantiateFromNib()
                navBar.titleView = titleView
            }
        }
        else {
            // This controller is appearing because another was just dismissed
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        
        syncVideos.onNext(())
    }
    
    private func configureTableView() {
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;

        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = 106
        tableView.registerCell(type: VideoViewCell.self)
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        
//        if #available(iOS 10.0, *) {
//            tableView.refreshControl = refreshControl
//        } else {
//            tableView.addSubview(refreshControl)
//        }
    }
    
    // MARK: BindableType
    func bindViewModel() {
        assert(viewModel != nil)
        
        let viewWillAppear = rx.sentMessage(#selector(VideosViewController.viewWillAppear(_:)))
            .mapToVoid()
            .catchErrorJustComplete()
        let pull = refreshControl.rx
            .controlEvent(.valueChanged)
            .asObservable()
        
        let selection = tableView.rx.itemSelected.asObservable()
//        let selection = Observable.just(IndexPath(row: 0, section: 0))
        let trigger = Observable.merge(viewWillAppear, pull)
        let input = VideosViewModel.Input(trigger: trigger,
                                          sync: syncVideos.asObservable(),
                                          selection: selection,
                                          delete: deletedVideo.asObservable())
        let output = viewModel.transform(input: input)
        
        dataSource = RxTableViewRealmDataSource<RMVideo>(cellIdentifier: String(describing: VideoViewCell.self), cellFactory: { ds, tv, ip, video in
            var cell = tv.dequeueReusableCell(withIdentifier: ds.cellIdentifier, for: ip) as! VideoViewCell
            let viewModel = VideoViewCellModel(video: video.asDomain())
            cell.bind(to: viewModel)
            cell.delegate = self
            return cell
        })
        
        output.videos
            .distinctUntilChanged()
            .flatMapLatest { Observable.changeset(from: $0) }
            .do(onNext: { (items, changeset) in
                if changeset?.inserted.count == 1, let addedVideo = items.first?.asDomain() {
                    DispatchQueue.main.async {
                        self.presentedViewController?.dismiss(animated: true, completion: nil)
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        self.shareVideo(addedVideo)
                    }
                }

                if items.count > 0 {
                    self.hasVideos = true
                    self.navBar?.trailingBarButtonItem = self.infoButtonItem
                } else {
                    self.hasVideos = false
                    self.navBar?.trailingBarButtonItem = nil
                }

                self.endLoading()
            })
            .bind(to: tableView.rx.realmChanges(dataSource))
            .disposed(by: disposeBag)
        
        output.fetching
            .do(onNext: { fetching in
                print("fetching \(fetching)")
            })
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        output.synced.subscribe().disposed(by: disposeBag)
        
        //move to View Model
        output.selectedVideo
            .flatMap { [unowned self] video in self.goToStatsAction.execute(video) }
            .subscribe()
            .disposed(by: disposeBag)
        
        output.deletedVideo.subscribe().disposed(by: disposeBag)
    }
    
    @objc func addTapped() {
        //show alert
        let alert = UIAlertController(title: "Add Youtube video", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "URL"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let youtubeURL = alert.textFields?.first?.text {
                print("Your name: \(youtubeURL)")
            }
        }))
        
        self.present(alert, animated: true)
    }

    func shareVideo(_ video: Video, callback: UIActivityViewControllerCompletionWithItemsHandler? = nil) {
        let link = NSURL(string: App.trackingPageBaseURL + video.uid)!
        let activityViewController = UIActivityViewController(activityItems: [link, ActionExtensionBlockerItem()] , applicationActivities: nil)
        activityViewController.completionWithItemsHandler = callback
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func openStoreProductWithiTunesItemIdentifier(identifier: NSNumber) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        self.present(storeViewController, animated: true)
        
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]

        storeViewController.loadProduct(withParameters: parameters)
    }
    
    @objc func openYouTube() {
        let application = UIApplication.shared
        let appURL = URL(string: "youtube://")!
        if application.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                application.open(appURL)
            } else {
                application.openURL(appURL)
            }
        } else {
            // if Youtube app is not installed, go to Store
            let youtubeId = 544007664
            openStoreProductWithiTunesItemIdentifier(identifier: youtubeId as NSNumber)
        }
    }
    
    @objc func showNoVideos() {
        let noVideosView = NoVideosView.instantiateFromNib()
        noVideosView.onTap = {
            if let presentedVC = self.presentedViewController {
                presentedVC.dismiss(animated: true, completion: {
                    self.openYouTube()
                })
            } else {
                self.openYouTube()
            }
        }
        let vc = ExampleViewController(with: noVideosView)
        
        customPresentViewController(customPresenter, viewController: vc, animated: true)
    }
}

extension VideosViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension VideosViewController: MGSwipeTableCellDelegate {
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        guard direction == MGSwipeDirection.rightToLeft else {
            return false
        }
        return true;
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        
        guard direction == MGSwipeDirection.rightToLeft else {
            return nil
        }
        
        swipeSettings.transition = MGSwipeTransition.border;
        
        expansionSettings.buttonIndex = 0;
        expansionSettings.fillOnTrigger = true;
        expansionSettings.threshold = 1.5;
        let padding = 25;
        
        let trash = MGSwipeButton(title: "", icon: UIImage(named: "trash"), backgroundColor: UIColor(hexString: "#f44336"), padding: padding) { (cell)
            -> Bool in
            let indexPath = self.tableView.indexPath(for: cell)!
            self.deletedVideo.onNext(indexPath)
            return false; //don't autohide to improve delete animation
        }
        
        let share = MGSwipeButton(title: "", icon: UIImage(named: "share"), backgroundColor: UIColor(hexString: "#1976d2"), padding: padding) { (cell) -> Bool in
            let indexPath = self.tableView.indexPath(for: cell)!
            let video = self.dataSource.model(at: indexPath).asDomain()
            self.shareVideo(video, callback: { (activity, completed, returnedItems, error) in
                cell.hideSwipe(animated: true)
            })
            return false; // Don't autohide
        }
        
        return [trash, share]
    }
}

extension VideosViewController: StatefulViewController {
    var backingView: UIView {
        return containerView
    }
    
    func hasContent() -> Bool {
        return hasVideos
    }
    
    func handleErrorWhenContentAvailable(_ error: Error) {

    }
}

class ExampleViewController: UIViewController {
    
    private let injectedView: UIView
    
    init(with view: UIView) {
        injectedView = view
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = injectedView
    }
}
