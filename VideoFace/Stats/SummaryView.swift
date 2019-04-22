//
//  SummaryView.swift
//  VideoFace
//
//  Created by Marco Rossi on 27/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import UICircularProgressRing

class SummaryView: UIView {
    @IBOutlet fileprivate var emotionLabels: [UILabel]!
    @IBOutlet fileprivate var emotionProgress: [UICircularProgressRing]!
    
    @IBOutlet fileprivate var ageLabels: [UILabel]!
    @IBOutlet fileprivate var ageProgress: [UICircularProgressRing]!
    
    @IBOutlet fileprivate var genderLabels: [UILabel]!
    @IBOutlet fileprivate var genderProgress: [UICircularProgressRing]!
    
    @IBOutlet fileprivate weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        let allCircles = [emotionProgress!, ageProgress!, genderProgress!]
        for circle in Array(allCircles.joined()) {
            self.commonSetupForCircle(circle)
        }
    }
    
    private func commonSetupForCircle(_ circle: UICircularProgressRing) {
        circle.ringStyle = .ontop
        circle.minValue = 0
        circle.maxValue = 100
        circle.startAngle = 270
        circle.font = UIFont(name: "Raleway-Regular", size: 14)!
        circle.innerRingWidth = 5
        circle.outerRingWidth = 5
        circle.showFloatingPoint = false
        circle.outerRingColor = UIColor.clear
    }
    
    func setData(_ data: SummaryData) {
        //Emotions
        let emotionStats = data.emotionStats
        for (index, stat) in emotionStats.enumerated() {
            let label = self.emotionLabels[index]
            label.text = stat.emotion.title.localized()
            let progress = self.emotionProgress[index]
            progress.innerRingColor = stat.emotion.color
            progress.value = UICircularProgressRing.ProgressValue(stat.value!.roundToDecimal(2) * 100)
        }
        
        //Ages
        let ages = data.ages
        for (index, age) in ages.enumerated() {
            let progress = self.ageProgress[index]
            progress.innerRingColor = UIColor.gray
            progress.value = UICircularProgressRing.ProgressValue(age.roundToDecimal(2) * 100)
        }
        
        //Gender
        let gender = data.genders
        let femaleProgress = genderProgress[1]
        femaleProgress.innerRingColor = UIColor(hexString: "#f29699")
        femaleProgress.value = UICircularProgressRing.ProgressValue(gender.female.roundToDecimal(2) * 100)
        let maleProgress = genderProgress[0]
        maleProgress.innerRingColor = UIColor(hexString: "#3c63ad")
        maleProgress.value = UICircularProgressRing.ProgressValue(gender.male.roundToDecimal(2) * 100)
        
        //adjust labels font
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stackView.layoutSubviews()
        
        let width = stackView.arrangedSubviews.first!.bounds.size.width
        
        //adjust labels font
        let longestLabel = self.emotionLabels.getLongestLabel()
        let fontSize = longestLabel.getApproximateAdjustedFontSize(width: width)
        for label in emotionLabels! {
            label.font = label.font.withSize(fontSize)
        }
    }

}
