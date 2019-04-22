//
//  RealmUseCaseProvider.swift
//  VideoFace
//
//  Created by Marco Rossi on 19/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Moya

public final class RealmUseCaseProvider: UseCaseProvider {
    
    private let configuration: Realm.Configuration
    
    public init(configuration: Realm.Configuration = Realm.Configuration()) {
        self.configuration = configuration
    }
    
    public func makeVideosUseCase() -> VideosUseCaseType {
        let repository = Repository<Video>(configuration: configuration)
        let service = YouTubeService()
        
        return RealmVideosUseCase(repository: repository, service: service)
    }
    
    public func makeStatsUseCase() -> StatsUseCaseType {
        let stubService = StatService(provider: MoyaProvider<ApiFace>(stubClosure: MoyaProvider.immediatelyStub))
        let service = StatService()
        return StatsUseCase(service: service)
    }
}
