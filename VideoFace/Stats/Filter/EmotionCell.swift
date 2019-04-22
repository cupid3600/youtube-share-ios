//
//  EmotionCell.swift
//  VideoFace
//
//  Created by Marco Rossi on 18/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

class EmotionCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var emotionLabel: UILabel!
    @IBOutlet fileprivate weak var emojiCircle: UIView!
    @IBOutlet fileprivate weak var emojiContainer: UIView!
    
    var item: EmotionItem? {
        didSet {
            emotionLabel?.text = item?.title.uppercased()
            emojiCircle.backgroundColor = item?.color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        emojiCircle.layer.cornerRadius = emojiCircle.bounds.size.width * 0.5
        emojiCircle.layer.masksToBounds = true
        
        selectionStyle = .none
        tintColor = UIColor.black
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
}
