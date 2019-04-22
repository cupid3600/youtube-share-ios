//
//  StatsUseCase.swift
//  VideoFaceTests
//
//  Created by Marco Rossi on 07/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift

final class StatsUseCase: StatsUseCaseType {
    
    private let service: StatServiceType
    
    init(service: StatServiceType) {
        self.service = service
    }
    
    func stats(id: String) -> Observable<[Stat]> {
        return service.stats(id: id)
    }
}


