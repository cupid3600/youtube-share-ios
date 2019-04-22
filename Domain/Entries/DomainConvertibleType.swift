//
//  DomainConvertibleType.swift
//  VideoFace
//
//  Created by Marco Rossi on 18/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

protocol DomainConvertibleType {
    associatedtype DomainType
    
    func asDomain() -> DomainType
}

extension Sequence {
    func forEach(_ closure: (Element) -> () -> Void) {
        for element in self {
            closure(element)()
        }
    }
}

//extension Sequence where Self.Iterator.Element: DomainConvertibleType {
//    func asDomain() -> [Iterator.Element] {
//        return self.forEach(DomainConvertibleType.asDomain)
//    }
//}

