//
//  VideoStatsViewModel.swift
//  VideoFace
//
//  Created by Marco Rossi on 04/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class VideoStatsViewModel: ViewModelType {
    
    struct Input {
        let trigger: Observable<Void>
    }
    struct Output {
        let fetching: Driver<Bool>
        let data: Observable<(samples: [EmotionSample], summary: SummaryData)>
        let error: Driver<Error>
    }
    
    // MARK: Private
    let video: Video
    private let useCase: StatsUseCaseType
//    private let coordinator: SceneCoordinatorType
    
    init(video: Video, useCase: StatsUseCaseType = RealmUseCaseProvider().makeStatsUseCase() as! StatsUseCase) {
        self.video = video
        self.useCase = useCase
//        self.coordinator = coordinator
    }
    
    deinit {
        print("deinit")
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
    
        let stats = input.trigger.flatMapLatest {_ in
            self.useCase.stats(id: self.video.uid)
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .catchErrorJustComplete()
        }.share()
        
        let data = stats.map(self.extractData)
        let fetching = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        
        return Output(fetching: fetching,
                      data: data,
                      error: errors)
    }
    
    func extractData(stats: [Stat]) -> (samples: [EmotionSample], summary: SummaryData) {
        let samples = Dictionary(grouping: stats, by: { $0.vTime })
            .map { (arg) -> EmotionSample in
                let (time, stats) = arg
                return EmotionSample(time: Double(time), faces: stats.counter, emotions: stats.normalizedEmotions)
            }.sorted(by: { $0.time < $1.time })
        
        let summary = SummaryData(stats: stats)
        
        return (samples: samples, summary: summary)
    }
}

typealias EmotionStat = (emotion: Emotion, value: Double?)

public class SummaryData {
    private let stats: [Stat]
    
    private lazy var values: [Int:[Stat]] = {
        return Dictionary(grouping: stats, by: { $0.vTime })
    }()
    
    init(stats: [Stat]) {
        self.stats = stats
    }
    
    var emotionStats: [EmotionStat] {
        let emotions: [Emotion] = [.happiness, .surprise, .sadness, .fear, .disgust, .anger]
        let emotionSum = self.values
            .mapValues { $0.normalizedEmotions }
            .map { $0.value }
            .reduce(([String:Double]())) { $0.merging($1, uniquingKeysWith: +) }
        
        return emotionSum
            .mapValues { $0 / Double(values.keys.count) }
            .map { EmotionStat(emotion: Emotion($0.key)!, value: $0.value) }
            .sorted(by: { (emotions.firstIndex(of: $0.emotion))! <  (emotions.firstIndex(of: $1.emotion))!})
    }
    
    var genders: Genders {
        let normalizedGenders = self.values.mapValues { $0.normalizedGenders }.map { $0.value }
        let sum = normalizedGenders
            .reduce(Genders(female: 0,male: 0), { Genders(female: ($0.female + $1.female), male: ($0.male + $1.male))
        })
        
        let count = Double(normalizedGenders.count)
        return Genders(female: (sum.female / count), male: (sum.male / count))
    }
    
    var ages: [Double] {
        let normalizedAges = self.values.mapValues { $0.normalizedAges }.map { $0.value }
        let sum = normalizedAges
            .reduce([0.0, 0.0, 0.0, 0.0]) { (result, next) in zip(result,next).map(+) }
            .map { $0 / Double(normalizedAges.count) }
        return sum
    }
}

public class EmotionSample {
    let time: Double
    let faces: Int
    private let emotions: [String:Double]
    
    var stats : [EmotionStat] {
        let anger = EmotionStat(emotion: Emotion.anger, value: emotions[Emotion.anger.description])
        let disgust = EmotionStat(emotion: Emotion.disgust, value: emotions[Emotion.disgust.description])
        let fear = EmotionStat(emotion: Emotion.fear, value: emotions[Emotion.fear.description])
        let sadness = EmotionStat(emotion: Emotion.sadness, value: emotions[Emotion.sadness.description])
        let surprise = EmotionStat(emotion: Emotion.surprise, value: emotions[Emotion.surprise.description])
        //        let rested = EmotionStat(emotion: Emotion.rested, value: emotions[Emotion.rested.description])
        let happiness = EmotionStat(emotion: Emotion.happiness, value: emotions[Emotion.happiness.description])
        
        return [happiness, surprise, sadness, fear, disgust, anger]
    }
    
    init(time: Double, faces: Int, emotions: [String:Double]) {
        self.time = time
        self.faces = faces
        self.emotions = emotions
    }
}
