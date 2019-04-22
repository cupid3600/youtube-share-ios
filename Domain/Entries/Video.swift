//
//  Video.swift
//  VideoFace
//
//  Created by Marco Rossi on 18/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

public enum VideoType: Int {
    case unknown
    case youtube
}

public struct Video {
    public let type: VideoType
    public let uid: String
    var url: String? {
        switch type {
        case .youtube:
            let youtubeUrl = "https://youtu.be/"
            return youtubeUrl + uid
        default:
            return nil
        }
    }
    
    //Details
    public var title: String?
    public var description: String?
    public var thumbnailUrl: String?
    public var duration: TimeInterval?
    public var publishedAt: Date?
    
    public init?(youtubeUrl: String) {
        if let youtubeID = youtubeUrl.youtubeID {
            self.type = VideoType.youtube
            self.uid = youtubeID
        } else {
            return nil
        }
    }
    
    public init(type: VideoType = VideoType.youtube,
                uid: String,
                title: String? = nil,
                description: String? = nil,
                thumbnailUrl: String? = nil,
                duration: TimeInterval? = nil,
                publishedAt: Date? = nil) {
        self.type = type
        self.uid = uid
        self.title = title
        self.description = description
        self.thumbnailUrl = thumbnailUrl
        self.duration = duration
        self.publishedAt = publishedAt
    }
}

extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        
        guard let result = regex?.firstMatch(in: self, options: [], range: range) else {
            return nil
        }
        
        return (self as NSString).substring(with: result.range)
    }
}
