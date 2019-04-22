//
//  Date+YouTube.swift
//  VideoFace
//
//  Created by Marco Rossi on 25/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

extension Date {
    fileprivate static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        
        return formatter
    }()
    
    func youtubeString() -> String {
        let timeString = Date.formatter.string(from: self)
        return timeString
    }
}
