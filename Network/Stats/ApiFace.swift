//
//  ApiFace.swift
//  VideoFace
//
//  Created by Marco Rossi on 05/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import Moya

enum ApiFace {
    case stats(id: String)
}

extension ApiFace: Moya.TargetType {
    var baseURL: URL {
        guard let url = URL(string: "https://apiface.morphcast.com/v1") else {
            fatalError("FAILED Face API")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .stats(let id):
            return "/stats/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .stats:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .stats:
            return stubbedResponse("Stats")
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        default:
            return nil
        }
    }
    
    var task: Task {
        let encoding: ParameterEncoding
        switch self.method {
        case .post:
            encoding = JSONEncoding.default
        default:
            encoding = URLEncoding.default
        }
        if let requestParameters = parameters {
            return .requestParameters(parameters: requestParameters, encoding: encoding)
        }
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
}

// MARK: - Provider support

func stubbedResponse(_ filename: String) -> Data! {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    let path = bundle.path(forResource: filename, ofType: "json")
    return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
}
