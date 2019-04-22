//
//  StatsViewCellModel.swift
//  VideoFace
//
//  Created by Marco Rossi on 08/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift

protocol StatsViewCellModelOutput {
    var time: Observable<String>! { get }
    var stats: [EmotionStat]! { get }
}

class StatsViewCellModel: StatsViewCellModelOutput {
    // MARK: Outputs
    var outputs: StatsViewCellModelOutput { return self }
    
    var time: Observable<String>!
    var stats: [EmotionStat]!
   
    init(time: Double, stats: [EmotionStat]) {
        self.time = Observable.just("\(Int(time)) sec")
        self.stats = stats
    }
}
