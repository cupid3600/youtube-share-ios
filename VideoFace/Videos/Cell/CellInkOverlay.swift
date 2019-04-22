//
//  CellInkOverlay.swift
//  VideoFace
//
//  Created by Marco Rossi on 03/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialInk

class CellInkOverlay: UIView, MDCInkTouchControllerDelegate {
    
    fileprivate var inkTouchController: MDCInkTouchController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.inkTouchController = MDCInkTouchController(view:self)
        self.inkTouchController!.defaultInkView.inkColor = UIColor(hexString: "#edf0fa")
        self.inkTouchController!.delaysInkSpread = true
        self.inkTouchController!.addInkView()
        self.inkTouchController!.delegate = self
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
