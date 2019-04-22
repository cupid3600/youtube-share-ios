//
//  NoVideosView.swift
//  VideoFace
//
//  Created by Marco Rossi on 09/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_ButtonThemer

class NoVideosView: UIView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: MDCButton!
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    func setupView() {
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let localizedContent = NSLocalizedString("No_videos", comment: "")
        label.text = localizedContent
        let title = "Open_youtube".localized()
        button.setTitle(title, for: .normal)
        let font = UIFont(name: "Raleway-Bold", size: 15)!
        button.setTitleFont(font, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setBackgroundColor(UIColor.red, for: .normal)
        button.layer.cornerRadius = 8
//        button.minimumSize = CGSize(width: button.bounds.width, height: 48)
//        button.setElevation(ShadowElevation(2), for: .normal)
//        button.setElevation(ShadowElevation(8), for: .highlighted)
//        MDCContainedButtonThemer.applyScheme(buttonScheme, to: button)
    }
    
    
    // MARK: - Actions
    @IBAction func didTapButton(sender: UIButton) {
        self.onTap?()
    }
    
}
