//
//  StatView.swift
//  VideoFace
//
//  Created by Marco Rossi on 22/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class StatView: UIView {
    
    @IBOutlet fileprivate weak var circleView: UIView!
    @IBOutlet fileprivate weak var container: UIView!
    @IBOutlet fileprivate weak var countLabel: UILabel!
    
    // MARK: Private
    private var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
//        circleView.layer.cornerRadius = circleView.bounds.size.width * 0.5
//        circleView.layer.masksToBounds = true
    }
    
}
