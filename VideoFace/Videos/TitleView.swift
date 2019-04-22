//
//  TitleView.swift
//  VideoFace
//
//  Created by Marco Rossi on 07/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import UIKit

class TitleView: UIView {
    
    // MARK: IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
    }
    
}
