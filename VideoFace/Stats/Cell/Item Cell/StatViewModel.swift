//
//  StatViewModel.swift
//  VideoFace
//
//  Created by Marco Rossi on 10/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit
import RxSwift

protocol StatViewCellModelOutput {
    var value: Observable<String>! { get }
    var color: Observable<UIColor>! { get }
//    var image: Observable<UIImage>! { get }
}

class StatViewModel: StatViewCellModelOutput {
    // MARK: Outputs
    var outputs: StatViewCellModelOutput { return self }
    var value: Observable<String>!
    var color: Observable<UIColor>!
//    var image: Observable<UIImage>!
    
    let stat: EmotionStat
    init(stat: EmotionStat) {
        self.stat = stat
        let value = "\(stat.value)"
        self.value = Observable.just(value)
        self.color = Observable.just(stat.emotion.color)
    }
}

extension StatViewModel: Equatable {
    public static func ==(lhs: StatViewModel, rhs: StatViewModel) -> Bool {
        return lhs.stat == rhs.stat
    }
}
