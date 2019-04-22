//
//  VideoViewCellModel.swift
//  VideoFace
//
//  Created by Marco Rossi on 26/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift

protocol VideoViewModelOutput {
    var thumbnailURL: Observable<URL>! { get }
    var title: Observable<String>! { get }
    var channel: Observable<String>! { get }
    var duration: Observable<String>! { get }
    var publishDate: Observable<String> { get }
}

class VideoViewCellModel: VideoViewModelOutput {
    
    var outputs: VideoViewModelOutput { return self }
    
    // MARK: Output
    var thumbnailURL: Observable<URL>!
    var title: Observable<String>!
    var channel: Observable<String>!
    var duration: Observable<String>!
    var publishDate: Observable<String>
    
    let videoStream: Observable<Video>!
    
    // MARK: Init
    init(video: Video) {
        self.videoStream = Observable.just(video)
        
        //check updated or not (sync)
        thumbnailURL = videoStream.map { $0.thumbnailUrl }.filterNil().map { URL(string: $0) }.filterNil()
        title = videoStream.map { $0.title ?? $0.url }.filterNil()
        channel = videoStream.map { $0.description }.replaceNilWith("")
        duration = videoStream.map { $0.duration }.filterNil().map{ $0.youtubeDuration() }
        publishDate = videoStream.map { $0.publishedAt?.youtubeString() }.replaceNilWith("")
    }    
}
