//
//  StatServiceType.swift
//  VideoFace
//
//  Created by Marco Rossi on 05/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift

public protocol StatServiceType {
    func stats(id: String) -> Observable<[Stat]>
}
