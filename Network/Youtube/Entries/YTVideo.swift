//
//  YTVideo.swift
//  VideoFace
//
//  Created by Marco Rossi on 19/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import ObjectMapper

struct YTThumbnail: ImmutableMappable {
    let url: String
    let height: Int
    let width: Int
    
    init(map: Map) throws {
        url = try map.value("url")
        width = try map.value("width")
        height = try map.value("height")
    }
}

struct YTThumbnails: Mappable {
    var _default: YTThumbnail?
    var medium: YTThumbnail?
    var high: YTThumbnail?
    var standard: YTThumbnail?
    var maxres: YTThumbnail?
    
    let keys = ["default", "medium", "high", "standard", "maxres"]
    var all: [YTThumbnail] = []
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        for aKey in keys {
            var thumb: YTThumbnail?
            thumb <- map[aKey]
            
            if thumb != nil {
                all.append(thumb!)
            }
        }
        _default <- map["default"]
        medium <- map["medium"]
        high <- map["high"]
        standard <- map["standard"]
        maxres <- map["maxres"]
    }
    
    var defaultURL: String? {
        return standard?.url ?? high?.url ?? medium?.url ?? _default?.url
    }
}

struct YTVideo: ImmutableMappable {
    let id: String
    //Details
    let title: String
    let channel: String
    let thumbnails: YTThumbnails
    let duration: String
    let publishedAt: Date
    
    init(map: Map) throws {
        // JSON -> Object
        id = try map.value("id")
        title = try map.value("snippet.title")
        channel = try map.value("snippet.channelTitle")
        thumbnails = try map.value("snippet.thumbnails")
        duration = try map.value("contentDetails.duration")
        publishedAt = try map.value("snippet.publishedAt", using: YoutubeDateTransform())
    }
}

extension YTVideo: DomainConvertibleType {
    func asDomain() -> Video {
        return Video(uid: id,
                     title: title,
                     description: channel,
                     thumbnailUrl: thumbnails.defaultURL,
                     duration: duration.youtubeDuration,
                     publishedAt: publishedAt)
    }
}

extension String {
    var youtubeDuration: TimeInterval {
        return self.getDuration(ISO8601String: self)
    }
    
    func getDuration(ISO8601String string: String) -> TimeInterval {
        var duration: TimeInterval = 0
        if let components = dateComponents(ISO8601String: self) {
            let seconds = components.second ?? 0
            let minutes = (components.minute ?? 0) * 60
            let hours = (components.hour ?? 0) * 3600
            duration = TimeInterval(seconds + minutes + hours)
        }
        return duration
    }
}

class YoutubeDateTransform: DateFormatterTransform {
    
    static let reusableYoutubeDateFormatter = DateFormatter(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", locale: "en_US_POSIX")
    
    public init() {
        super.init(dateFormatter: YoutubeDateTransform.reusableYoutubeDateFormatter)
    }
}

