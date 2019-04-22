//
//  Stat+Mappable.swift
//  VideoFace
//
//  Created by Marco Rossi on 05/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import ObjectMapper

extension Stat: ImmutableMappable {

    public init(map: Map) throws {
        counter = try map.value("counter")
        vTime = try map.value("v_time")
        uTime = try map.value("u_time")
        genders = try map.value("genders")
        emotions = try map.value("emotions")
        source = try map.value("source")
        urlID = try map.value("url_id")
        ages = try map.value("ages")
    }
}

extension Genders: ImmutableMappable {
    
    public init(map: Map) throws {
        female = (try? map.value("female")) ?? 0
        male = (try? map.value("male")) ?? 0
    }
}
