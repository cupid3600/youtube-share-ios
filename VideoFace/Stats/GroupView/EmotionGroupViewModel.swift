//
//  EmotionGroupViewModel.swift
//  VideoFace
//
//  Created by Marco Rossi on 22/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import RxSwift

class EmotionStatItem {
    let emotion: Emotion
    
    var isEnabled: Bool
    
    var title: String {
        return emotion.title.localized()
    }
    
    var image: UIImage {
        switch emotion {
        case .anger:
            return #imageLiteral(resourceName: "angry")
        case .disgust:
            return #imageLiteral(resourceName: "disgust.pdf")
        case .fear:
            return #imageLiteral(resourceName: "fear")
        case .sadness:
            return #imageLiteral(resourceName: "sad")
        case .surprise:
            return #imageLiteral(resourceName: "surprise")
        case .rested:
            return #imageLiteral(resourceName: "neutral")
        case .happiness:
            return #imageLiteral(resourceName: "happy")
        }
    }
    
    var color: UIColor {
        return emotion.color
    }
    
    init(emotion: Emotion, enabled: Bool = true) {
        self.emotion = emotion
        self.isEnabled = enabled
    }
}

protocol EmotionGroupModelOutput {
    var values: Observable<[String]>! { get }
    var colors: Observable<[UIColor]>! { get }
    var items: Observable<[EmotionStatItem]>! { get }
}

protocol StackViewDelegate {
    func didTapOnView(at index: Int)
}

class EmotionGroupViewModel: EmotionGroupModelOutput {
    
    // MARK: Outputs
    var outputs: EmotionGroupModelOutput { return self }

    private let itemsSubject: BehaviorSubject<[EmotionStatItem]>
    private let valuesSubject: BehaviorSubject<[String]> = BehaviorSubject(value: [])
    
    var values: Observable<[String]>!
    var items: Observable<[EmotionStatItem]>!
    var colors: Observable<[UIColor]>!
    
    let _items: [EmotionStatItem]
    
    var didToggleSelection:((_ enabledItems: [EmotionStatItem]) -> Void)? 
    
    var enabledItems: [EmotionStatItem] {
        return _items.filter { return $0.isEnabled }
    }
    
    init(items: [EmotionStatItem]) {
        self._items = items
        self.itemsSubject = BehaviorSubject(value: items)
        self.items = itemsSubject.asObservable()
        
        self.values = valuesSubject.asObservable()
        
        self.colors = Observable.just(items.map { $0.color })
    }
    
    func setStats(_ stats: [EmotionStat]) {
        let emotions = _items.map { $0.emotion }
        let values = stats
            .sorted { emotions.index(of: $0.emotion)! < emotions.index(of: $1.emotion)! }
            .map { stat -> String in
            guard let value = stat.value else {
                return ""
            }
            return String(format: "%.0f%%", value.roundToDecimal(2) * 100)
        }
        valuesSubject.onNext(values)
    }
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

extension EmotionGroupViewModel: StackViewDelegate {
    func didTapOnView(at index: Int) {
        // update ViewModel item
        let enabled = _items[index].isEnabled
        //at least one element selected
        if enabled && enabledItems.count == 1 {
            return
        }
        
        _items[index].isEnabled = !enabled
        itemsSubject.onNext(_items)
        
        didToggleSelection?(enabledItems)
    }
}
