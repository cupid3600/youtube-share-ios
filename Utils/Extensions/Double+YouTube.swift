//
//  Double+YouTube.swift
//  VideoFace
//
//  Created by Marco Rossi on 25/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    fileprivate static let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    func youtubeDuration() -> String {
        TimeInterval.formatter.zeroFormattingBehavior = .pad
        TimeInterval.formatter.allowedUnits = [.minute, .second]
        
        if self >= 3600 {
            TimeInterval.formatter.allowedUnits.insert(.hour)
        }
        
        return TimeInterval.formatter.string(from: self)!
    }
}
