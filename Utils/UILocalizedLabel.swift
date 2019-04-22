//
//  UILabel+Localized.swift
//  VideoFace
//
//  Created by Marco Rossi on 20/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit

final class UILocalizedLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        text = text?.localized()
    }
}
