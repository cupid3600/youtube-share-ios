//
//  Localizable.swift
//  VideoFace
//
//  Created by Marco Rossi on 19/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

extension String {
    
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}
