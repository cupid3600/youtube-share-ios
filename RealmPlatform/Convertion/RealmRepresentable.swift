//
//  RealmRepresentable.swift
//  VideoFace
//
//  Created by Marco Rossi on 18/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

protocol RealmRepresentable {
    associatedtype RealmType: DomainConvertibleType
    
    var uid: String { get }
    
    func asRealm() -> RealmType
}
