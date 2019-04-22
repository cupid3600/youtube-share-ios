//
//  Stat.swift
//  VideoFace
//
//  Created by Marco Rossi on 05/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift

protocol StatType {
    var counter: Int { get }
    var vTime: Int { get }
    var genders: Genders { get }
    var emotions: [String:Double] { get }
    var urlID: String { get }
    var ages: [String: Int] { get }
    
    //Computed vars
    var normalizedEmotions: [String:Double] { get }
    var normalizedAges: [Double] { get }
    var normalizedGenders: Genders { get }
    var percentageEmotions: [String:Double] { get }
}

protocol StatSampleType: StatType {
    var uTime: Int { get }
    var source: String { get }
}

public struct Stat: StatSampleType {
    let counter, vTime, uTime: Int
    let genders: Genders
    let emotions: [String:Double]
    let source, urlID: String
    let ages: [String: Int]
    
    var normalizedGenders: Genders {
        return Genders(female: genders.female / Double(counter),
                                 male: genders.male / Double(counter))
    }
    
    var normalizedAges: [Double] {
        var ageArr = [0, 0, 0, 0]
        for (key, value) in ages {
            let age = Int(key)!
            if age < 18 {
                ageArr[0] += value
            } else if age <= 35 {
                ageArr[1] += value
            } else if age <= 54 {
                ageArr[2] += value
            } else {
                ageArr[3] += value
            }
        }
        
        return ageArr.map { Double($0) / Double(counter) }
    }
    
    var normalizedEmotions: [String:Double] {
        let noRested = emotions.filter { $0.key != "neutral" }
        let count = noRested.reduce(0.0) { (acc, pair) -> Double in
            return acc + pair.value
        }
        let filtered = noRested.mapValues { ($0 / count ) }
        return filtered
    }
    
    var percentageEmotions: [String:Double] {
        return normalizedEmotions.mapValues { $0.roundToDecimal(2) * 100 }
    }
}

struct Genders {
    let female: Double
    let male: Double
}

extension Array where Element == Stat {
    
    var ages: [String: Int] {
        return self.map { $0.ages }
            .reduce(([String:Int]())) { $0.merging($1, uniquingKeysWith: +) }
    }
    
    var genders: Genders {
        return self.map { $0.genders }
            .reduce(Genders(female: 0,male: 0), {
                Genders(female: ($0.female + $1.female), male: ($0.male + $1.male))
            })
    }
    
    var counter: Int {
        return self.map { $0.counter }.reduce(0, +)
    }
    
    var normalizedAges: [Double] {
        let mapped = self.map { $0.normalizedAges }
        
        let norm = mapped.reduce([0.0, 0.0, 0.0, 0.0]) { (result, next) in
                zip(result,next).map(+)
            }
            .map { $0 / Double(self.count) }
        return norm
    }
    
    var normalizedGenders: Genders {
        let sum = self.map { $0.normalizedGenders }
            .reduce(Genders(female: 0,male: 0), {
                Genders(female: ($0.female + $1.female), male: ($0.male + $1.male))
            })
        return Genders(female: (sum.female / Double(self.count)),
                                 male: (sum.male / Double(self.count)))
    }
    
    var normalizedEmotions: [String:Double] {
        return self.map { $0.normalizedEmotions }
            .reduce(([String:Double]())) { $0.merging($1, uniquingKeysWith: +) }
            .mapValues { $0 / Double(self.count) }
    }
    
    var percentageEmotions: [String:Double] {
        return normalizedEmotions.mapValues { $0.roundToDecimal(2) * 100 }
    }
}

// Emotions

enum Emotion: Int, CustomStringConvertible {
    case anger = 0
    case disgust
    case fear
    case sadness
    case surprise
    case rested
    case happiness
    
    var description: String {
        switch self {
        case .anger:
            return "anger"
        case .disgust:
            return "disgust"
        case .fear:
            return "fear"
        case .sadness:
            return "sadness"
        case .surprise:
            return "surprise"
        case .rested:
            return "neutral"
        case .happiness:
            return "happiness"
        }
    }
    
    var title: String {
        switch self {
        case .anger:
            return "Anger"
        case .disgust:
            return "Disgust"
        case .fear:
            return "Fear"
        case .sadness:
            return "Sad"
        case .surprise:
            return "Surprise"
        case .rested:
            return "Rested"
        case .happiness:
            return "Happy"
        }
    }
    
    var color: UIColor {
        switch self {
        case .anger:
            return UIColor(hexString: "#ff3333")
        case .disgust:
            return UIColor(hexString: "#99c667")
        case .fear:
            return UIColor(hexString: "#a56baa")
        case .sadness:
            return UIColor(hexString: "#3c63ad")
        case .surprise:
            return UIColor(hexString: "#f29699")
        case .rested:
            return UIColor(hexString: "#e2e2e1")
        case .happiness:
            return UIColor(hexString: "#f59e0f")
        }
    }
}

//extension Emotion: Equatable {}

extension Emotion {
    init?(_ value: String) {
        switch value.lowercased() {
        case "anger": self = .anger
        case "disgust": self = .disgust
        case "fear": self = .fear
        case "sadness": self = .sadness
        case "surprise": self = .surprise
        case "neutral": self = .rested
        case "happiness": self = .happiness
        default: return nil
        }
    }
}
