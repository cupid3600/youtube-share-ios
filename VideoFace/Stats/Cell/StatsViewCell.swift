//
//  StatsViewCell.swift
//  VideoFace
//
//  Created by Marco Rossi on 08/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import IGListKit

import MaterialComponents.MDCCardCollectionCell

class StatsViewCell: MDCCardCollectionCell, BindableType {
    
    // MARK: ViewModel
    var viewModel: StatsViewCellModel!
    
    // MARK: Private
    private var disposeBag = DisposeBag()
    
    lazy var timeLabel: UILabel = {
       let label = UILabel()
        label.text = "0 sec"
        return label
    }()
    
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: nil) }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: CGRect(x: 0, y: 0, width: collectionWidth, height: 0), collectionViewLayout: layout)
        view.backgroundColor = UIColor.red
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = false
        self.contentView.addSubview(view)
        return view
    }()
    
    var collectionWidth: CGFloat {
        return self.contentView.bounds.size.width - 8
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
//        self.setShadowElevation(.cardResting, for: .normal)
        self.backgroundColor = UIColor.white
        
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView)
            make.centerX.equalToSuperview()
        }
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom)
            make.width.equalTo(collectionWidth)
            make.bottom.equalTo(contentView).inset(4)
            make.centerX.equalToSuperview()
        }
    }
    
    func bindViewModel() {
        let outputs = viewModel.outputs
        outputs.time
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.reloadData(completion: nil)
    }
}

extension StatsViewCell: ListAdapterDataSource {
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let statSection = StatSection.from(stats: viewModel.stats)
        return [statSection]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return StatSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
}
