//
//  RealmVideosUseCase.swift
//  VideoFace
//
//  Created by Marco Rossi on 19/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift
import Realm
import RealmSwift

final class RealmVideosUseCase: VideosUseCaseType {
    
    private let repository: Repository<Video>
    private let service: VideoServiceType
    
    init(repository: Repository<Video>, service: VideoServiceType) {
        self.repository = repository
        self.service = service
    }
    
    func videos() -> Observable<[Video]> {
        return repository.queryAll()
    }
    
    func realmVideos() -> Observable<Results<RMVideo>> {
        return repository.queryAllResults()
    }
    
    func save(video: Video) -> Observable<Void> {
        return repository.save(entity: video)
    }
    
    func save(videos: [Video]) -> Observable<Void> {
        return repository.save(entities: videos)
    }
    
    func delete(video: Video) -> Observable<Void> {
        return repository.delete(entity: video)
    }
    
    func sync(videos: [Video]) -> Observable<Void> {
        let ids = videos.map { $0.uid }
        let videos = service.videos(ids: ids).flatMapLatest { return self.save(videos: $0) }
        return videos
    }
    
    func sync(video: Video) -> Observable<Void> {
        return service.video(id: video.uid).flatMapLatest {
            return self.save(video: $0)
        }
    }
}
