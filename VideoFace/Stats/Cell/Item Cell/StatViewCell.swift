//
//  StatViewCell.swift
//  VideoFace
//
//  Created by Marco Rossi on 10/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

class StatViewCell : UICollectionViewCell, BindableType {
    
    // MARK: ViewModel
    var viewModel: StatViewModel!
    
    @IBOutlet fileprivate weak var circleView: UIView!
    @IBOutlet fileprivate weak var container: UIView!
    @IBOutlet fileprivate weak var countLabel: UILabel!
    
    // MARK: Private
    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleView.layer.cornerRadius = circleView.bounds.size.width * 0.5
        circleView.layer.masksToBounds = true
    }
    
    func bindViewModel() {
        let outputs = viewModel.outputs
        
        outputs.value
        .bind(to: countLabel.rx.text)
        .disposed(by: disposeBag)
        
        outputs.color
        .subscribe(onNext: { [unowned self] color in
            self.circleView.backgroundColor = color
        })
        .disposed(by:disposeBag)
    }
    
    private func addImageNamed(_ imageName: String) {
        container.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        container.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(container)
        }
        
//        if imageName.contains(find: "happy") {
//            imageView.addImage(named: imageName, inset: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
//        } else if imageName.contains(find: "disgusted") {
//            imageView.addImage(named: imageName, inset: UIEdgeInsets(top: 3, left: -2, bottom: 0, right: -2))
//        } else if imageName.contains(find: "surprise") {
//            imageView.addImage(named: imageName, inset: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
//        } else if imageName.contains(find: "fear") {
//            imageView.addImage(named: imageName, inset: UIEdgeInsets(top: 5, left: -2, bottom: 0, right: -2))
//        } else if imageName.contains(find: "neutral") {
//            imageView.addImage(named: imageName, inset: UIEdgeInsets(top: 10, left: 2, bottom: -2, right: 2))
//        } else if imageName.contains(find: "angry") {
//            imageView.addImage(named: imageName, inset: UIEdgeInsets(top: 0, left: -2, bottom: -1, right: -2))
//        } else if imageName.contains(find: "sad") {
//            imageView.addImage(named: imageName, inset: UIEdgeInsets(top: 0, left: -2, bottom: -1, right: -2))
//        } else {
//            imageView.image = UIImage(named: imageName)
//        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
}

extension UIImageView {
    func addImage(named name: String,inset edgeinset:UIEdgeInsets) {
        guard let image = UIImage(named: name) else {
            return
        }
        let insetImage = image.withAlignmentRectInsets(edgeinset)
        self.image = insetImage
    }
}
