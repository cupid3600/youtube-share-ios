//
//  RMVideo.swift
//  VideoFace
//
//  Created by Marco Rossi on 18/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

final class RMVideo: Object {
    @objc private dynamic var _type: Int = VideoType.unknown.rawValue
    var type: VideoType {
        get { return VideoType(rawValue: _type)! }
        set { _type = newValue.rawValue }
    }
    @objc dynamic var uid: String = ""
    @objc dynamic var createdAt: Date = Date()
    
    //Details
    @objc dynamic var title: String? = nil
    @objc dynamic var descr: String? = nil
    @objc dynamic var thumbnailUrl: String? = nil
    let duration = RealmOptional<TimeInterval>()
    @objc dynamic var publishedAt: Date? = nil
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMVideo: DomainConvertibleType {
    func asDomain() -> Video {
        return Video(uid: uid,
                     title: title,
                     description: descr,
                     thumbnailUrl: thumbnailUrl,
                     duration: duration.value,
                     publishedAt: publishedAt)
    }
}

extension Video: RealmRepresentable {
    
    func asRealm() -> RMVideo {
        return RMVideo.build { object in
            object.type = type
            object.uid = uid
            object.title = title
            object.descr = description
            object.thumbnailUrl = thumbnailUrl
            object.duration.value = duration
            object.publishedAt = publishedAt
        }
    }
}


