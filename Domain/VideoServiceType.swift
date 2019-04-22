//
//  VideoServiceType.swift
//  Domain
//
//  Created by Marco Rossi on 20/09/2018.
//  Copyright © 2018 sergdort. All rights reserved.
//

import Foundation
import RxSwift

public protocol VideoServiceType {
    func video(id: String) -> Observable<Video>
    func videos(ids: [String]) -> Observable<[Video]>
}
