//
//  UseCaseLocator.swift
//  VideoFace
//
//  Created by Marco Rossi on 20/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

protocol UseCaseLocatorType {
    func getUseCase<T>(ofType type: T.Type) -> T?
}

class UseCaseLocator: UseCaseLocatorType {
    static let defaultLocator = UseCaseLocator(repository: Repository<Video>(),
                                               service: YouTubeService())
    
    fileprivate let repository: Repository<Video>
    fileprivate let service: VideoServiceType
    
    init(repository: Repository<Video>, service: VideoServiceType) {
        self.repository = repository
        self.service = service
    }
    
    func getUseCase<T>(ofType type: T.Type) -> T? {
        switch String(describing: type) {
        case String(describing: GetAppDetails.self):
            return buildUseCase(type: GetAppDetailsImpl.self)
        case String(describing: ListApps.self):
            return buildUseCase(type: ListAppsImpl.self)
        case String(describing: ListCategories.self):
            return buildUseCase(type: ListCategoriesImpl.self)
        case String(describing: SyncAppData.self):
            return buildUseCase(type: SyncAppDataImpl.self)
        default:
            return nil
        }
    }
}

private extension UseCaseLocator {
    func buildUseCase<U: UseCaseImpl, R>(type: U.Type) -> R? {
        return U(repository: repository, service: service) as? R
    }
}
