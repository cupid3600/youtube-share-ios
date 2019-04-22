//
//  EmotionGroupView.swift
//  VideoFace
//
//  Created by Marco Rossi on 22/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import IGListKit

class EmotionGroupView: UIView, BindableType {
    
    // MARK: ViewModel
    var viewModel: EmotionGroupViewModel!
    
    @IBOutlet fileprivate var containers: [UIView]!
    @IBOutlet fileprivate var titleLabels: [UILabel]!
    @IBOutlet fileprivate var countLabels: [UILabel]!
    @IBOutlet fileprivate weak var stackView: UIStackView!
    
    // MARK: Private
    private var disposeBag = DisposeBag()
    
    private var stackViewDelegate: StackViewDelegate?
    
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: nil) }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.red
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = false
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    func setupViews() {
        self.backgroundColor = UIColor.white
        
        configureTapGestures()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        stackView.layoutSubviews()
        
        let width = stackView.arrangedSubviews.first!.bounds.size.width
        
        let longestLabel = self.titleLabels.getLongestLabel()
        let fontSize = longestLabel.getApproximateAdjustedFontSize(width: width)
        self.titleLabels.forEach { label in
            label.font = label.font.withSize(fontSize)
        }
    }

    func getLongestLabel(_ labels: [UILabel]) -> UILabel {
        return labels.sorted(by:{
            let size0 = ($0.text! as NSString).size(withAttributes: [NSAttributedStringKey.font: $0.font])
            let size1 = ($1.text! as NSString).size(withAttributes: [NSAttributedStringKey.font: $1.font])
            return size0.width > size1.width
        }).first!
    }
    
    private func configureTapGestures() {
        for view in stackView.arrangedSubviews {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func didTapOnView(gestureRecognizer: UIGestureRecognizer) {
        if let index = stackView.arrangedSubviews.index(of: gestureRecognizer.view!) {
            stackViewDelegate?.didTapOnView(at: index)
        }
    }
    
    func bindViewModel() {
        let outputs = viewModel.outputs
        
        outputs.items
            .subscribe(onNext: { items in
                for (index, item) in items.enumerated() {
                    self.configure(item: item, at: index)
                }
            }).disposed(by: disposeBag)
        
        outputs.values
            .subscribe(onNext: { values in
                for (index, value) in values.enumerated() {
                    let label = self.countLabels[index]
                    label.text = value
                }
            }).disposed(by: disposeBag)
        
        stackViewDelegate = viewModel
    }
    
    func configure(item: EmotionStatItem, at index: Int) {
        let alpha = item.isEnabled ? 1.0 : 0.15
        let view = self.containers[index]
        view.backgroundColor = UIColor.clear
        view.alpha = CGFloat(alpha)
        if view.subviews.count == 0 {
            let imageView = UIImageView(image: item.image)
            view.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.edges.equalTo(view)
            }
        }
        
        let title = self.titleLabels[index]
        title.text = item.title
        
        title.alpha = CGFloat(alpha)
        
        let value = self.countLabels[index]
        value.alpha = CGFloat(alpha)
    }
}
