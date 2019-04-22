//
//  StatsUseCaseType.swift
//  VideoFaceTests
//
//  Created by Marco Rossi on 07/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift

public protocol StatsUseCaseType {
    func stats(id: String) -> Observable<[Stat]>
}
