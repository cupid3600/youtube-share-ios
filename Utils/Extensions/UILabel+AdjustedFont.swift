//
//  UILabel+AdjustedFont.swift
//  VideoFace
//
//  Created by Marco Rossi on 20/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

extension UILabel {
    func getApproximateAdjustedFontSize(width: CGFloat? = nil) -> CGFloat {
        let width = width ?? self.bounds.width
        
        if self.adjustsFontSizeToFitWidth == true {
            var currentFont: UIFont = self.font
            let originalFontSize = currentFont.pointSize
            var currentSize: CGSize = (self.text! as NSString).size(withAttributes: [NSAttributedStringKey.font: currentFont])
            
            while currentSize.width > width && currentFont.pointSize > (originalFontSize * self.minimumScaleFactor) {
                currentFont = currentFont.withSize(currentFont.pointSize - 1)
                currentSize = (self.text! as NSString).size(withAttributes: [NSAttributedStringKey.font: currentFont])
            }
            
            return currentFont.pointSize
        }
        else {
            return self.font.pointSize
        }
    }
}

extension Array where Element: UILabel {
    func getLongestLabel() -> UILabel {
        return self.sorted(by:{
            let size0 = ($0.text! as NSString).size(withAttributes: [NSAttributedStringKey.font: $0.font])
            let size1 = ($1.text! as NSString).size(withAttributes: [NSAttributedStringKey.font: $1.font])
            return size0.width > size1.width
        }).first!
    }
}
