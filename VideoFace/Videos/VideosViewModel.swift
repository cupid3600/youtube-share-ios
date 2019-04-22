//
//  VideosViewModel.swift
//  VideoFace
//
//  Created by Marco Rossi on 25/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import Action

final class VideosViewModel: ViewModelType {
    
    struct Input {
        let trigger: Observable<Void>
//        let add: Observable<Void>
        let sync: Observable<Void>
        let selection: Observable<IndexPath>
        let delete: Observable<IndexPath>
    }
    struct Output {
        let fetching: Driver<Bool>
        let videos: Observable<Results<RMVideo>>
        let selectedVideo: Observable<Video>
        let deletedVideo: Observable<Void>
        let synced: Observable<Void>
//        let addedVideo: Driver<Void>
        let error: Driver<Error>
    }
    
    lazy var addVideoAction: Action<String, Void> = {
        Action<String, Void> { [unowned self] url in
            let video = Video(youtubeUrl: url)
            return Observable.just(video)
                .filterNil()
                .flatMap { video in self.useCase.save(video: video).map { return video }}
                .flatMap { video in self.useCase.sync(video: video) }
        }
    }()
    
    // MARK: Private
    private let useCase: RealmVideosUseCase 
    private let coordinator: SceneCoordinatorType
    
    init(useCase: RealmVideosUseCase = RealmUseCaseProvider().makeVideosUseCase() as! RealmVideosUseCase, coordinator: SceneCoordinatorType = SceneCoordinator.shared) {
        self.useCase = useCase
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let videos = input.trigger.flatMapLatest {
            self.useCase.realmVideos()
//                .trackActivity(activityIndicator)
//                .trackError(errorTracker)
                .catchErrorJustComplete()
        }.share()
        
//        let synced = videos.flatMap { Observable.just($0.toArray().mapToDomain()) }.flatMap { videos in
//            self.useCase.sync(videos: videos)
//        }
        
        let synced = input.sync.flatMapLatest {_ in
//            self.useCase.videos().flatMap { self.useCase.sync(videos: $0) }
            self.useCase.videos().map { $0.filter {$0.title == nil } }.flatMap { self.useCase.sync(videos: $0) }
        }
        
        let fetching = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        let selectedVideo = input.selection.withLatestFrom(videos) { (indexPath, videos) -> Video in
            return videos[indexPath.row].asDomain()
            }
        
        let deletedVideo = input.delete.withLatestFrom(videos) { (indexPath, videos) -> Video in
            return videos[indexPath.row].asDomain()
            }.flatMapLatest { video in self.useCase.delete(video: video) }
        
//        let addedVideo = input.add.map { Video(uid: UUID().uuidString) }
//            .flatMapLatest { video in self.useCase.save(video: video) }
//            .asDriverOnErrorJustComplete()
        
        return Output(fetching: fetching,
                      videos: videos,
                      selectedVideo: selectedVideo,
                      deletedVideo: deletedVideo,
                      synced: synced,
//                      addedVideo: addedVideo,
                      error: errors)
    }
}
