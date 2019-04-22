//
//  YoutubeService.swift
//  VideoFace
//
//  Created by Marco Rossi on 19/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Moya_ObjectMapper
import RxOptional

struct YouTubeService: VideoServiceType {
    private var provider: MoyaProvider<YouTube>
    
    init(provider: MoyaProvider<YouTube> = MoyaProvider<YouTube>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        self.provider = provider
    }
    
    func video(id: String) -> Observable<Video> {
        return videos(ids: [id])
            .map { $0.first }
            .filterNil()
    }
    
    func videos(ids: [String]) -> Observable<[Video]> {
        return provider.rx
            .request(.list(ids: ids))
            .debug()
            .mapArray(YTVideo.self, atKeyPath: "items")
            .asObservable()
            .mapToDomain()
    }
}
