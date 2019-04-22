//
//  TopView.swift
//  VideoFace
//
//  Created by Marco Rossi on 13/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

class TopView: UIView {
    // MARK: IBOutlets
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        for circle in [circle1, circle2, circle3] {
//            circle?.minValue = 0
//            circle?.maxValue = 1
//            circle?.startAngle = 270
//            circle?.font = UIFont(name: "Raleway-Regular", size: 14)!
//            circle?.innerRingWidth = 5
//            circle?.outerRingWidth = 5
//            circle?.outerRingColor = UIColor(hexString: "#f0f2f6")
//            circle?.valueIndicator = ""
//            circle?.showFloatingPoint = true
//        }
    }
    
    func setFaces(faces: Int) {
        self.countLabel.text = "\(faces)"
        if faces == 1 {
            self.viewsLabel.text = "face".localized()
        } else {
            self.viewsLabel.text = "faces".localized()
        }
    }
}
