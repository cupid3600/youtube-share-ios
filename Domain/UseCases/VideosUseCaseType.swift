//
//  VideosUseCaseType.swift
//  VideoFace
//
//  Created by Marco Rossi on 18/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift

public protocol VideosUseCaseType {
    func videos() -> Observable<[Video]>
    func save(video: Video) -> Observable<Void>
    func delete(video: Video) -> Observable<Void>
}
