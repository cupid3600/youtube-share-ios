//
//  VideoViewCell.swift
//  VideoFace
//
//  Created by Marco Rossi on 25/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import RxSwift
import Nuke
import RxNuke

class VideoViewCell: MGSwipeTableCell, BindableType {
    
    // MARK: ViewModel
    var viewModel: VideoViewCellModel!
    
    // MARK: IBOutlets
    @IBOutlet private weak var thumbnailView: UIImageView!
    @IBOutlet private weak var durationBackgroundView: UIView!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var channelLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    
    // MARK: Private
    private var disposeBag = DisposeBag()
    private let inkOverlay = CellInkOverlay()
    
    // MARK: Overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!

        setupViews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        durationBackgroundView.layer.cornerRadius = 2
        durationBackgroundView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailView.image = nil
        disposeBag = DisposeBag()
    }
    
    func setupViews() {
        //Ink Overlay
        inkOverlay.frame = self.bounds
        inkOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(inkOverlay)
        contentView.sendSubview(toBack: inkOverlay)
    }
    
    // MARK: BindableType
    
    func bindViewModel() {
        let outputs = viewModel.outputs
        
        let scale = UIScreen.main.scale
        let widthInPixels = self.thumbnailView.frame.width * scale
        let heightInPixels = self.thumbnailView.frame.height * scale
        
        outputs.thumbnailURL
            .flatMap {
//                ImageRequest(url: $0, targetSize: CGSize(width: widthInPixels, height: heightInPixels), contentMode: .aspectFill)
                return ImagePipeline.shared.rx.loadImage(with: ImageRequest(url: $0, targetSize: CGSize(width: widthInPixels, height: heightInPixels), contentMode: .aspectFill)) 
            }
            .subscribe(onNext: { response in self.thumbnailView.image = response.image })
            .disposed(by: disposeBag)
        
        outputs.title
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        outputs.channel
            .bind(to: channelLabel.rx.text)
            .disposed(by: disposeBag)
        
        outputs.publishDate
            .bind(to: detailsLabel.rx.text)
            .disposed(by: disposeBag)
        
        outputs.duration
            .bind(to: durationLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
