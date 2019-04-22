//
//  UseCaseProvider.swift
//  VideoFace
//
//  Created by Marco Rossi on 18/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

public protocol UseCaseProvider {
    func makeVideosUseCase() -> VideosUseCaseType
    func makeStatsUseCase() -> StatsUseCaseType
}
