//
//  StatService.swift
//  VideoFace
//
//  Created by Marco Rossi on 05/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Moya_ObjectMapper

struct StatService: StatServiceType {
    private var provider: MoyaProvider<ApiFace>
    
    init(provider: MoyaProvider<ApiFace> = MoyaProvider<ApiFace>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        self.provider = provider
    }
    
    func stats(id: String) -> Observable<[Stat]> {
        return provider.rx
            .request(.stats(id: id))
            .mapArray(Stat.self)
            .asObservable()
            .debug()
    }
}
