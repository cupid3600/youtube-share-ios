//
//  StatSection.swift
//  VideoFace
//
//  Created by Marco Rossi on 10/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import IGListKit

class StatSection {
    
    let stats: [EmotionStat]
    let viewModels: [StatViewModel]
    
    init(stats: [EmotionStat], viewModels: [StatViewModel]) {
        self.stats = stats
        self.viewModels = viewModels
    }
    
    static func from(stats: [EmotionStat]) -> StatSection {
        return StatSection(stats: stats, viewModels: stats.map { StatViewModel(stat: $0) })
    }
}

extension StatSection: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return "stats" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? StatSection else { return false }
        return viewModels == object.viewModels
    }
    
}
