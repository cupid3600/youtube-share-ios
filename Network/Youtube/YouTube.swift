//
//  YouTube.swift
//  VideoFace
//
//  Created by Marco Rossi on 19/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import Moya

enum YouTube {
    case list(ids: [String])
}

private let apiKey = "AIzaSyAyEnjmPx3Ix2uDCWtFK_cxvUkOR2YyBb8"

extension YouTube: Moya.TargetType {
    var baseURL: URL {
        guard let url = URL(string: "https://www.googleapis.com/youtube/v3") else {
            fatalError("FAILED Youtube API")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .list:
            return "/videos"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .list:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        var params: [String:Any] = [:]
        params["key"] = apiKey
        switch self {
        case let .list(ids):
            params["part"] = "snippet, contentDetails, statistics"
            params["id"] = ids.joined(separator: ",")
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
