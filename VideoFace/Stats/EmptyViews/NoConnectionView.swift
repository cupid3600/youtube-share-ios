//
//  NoConnectionView.swift
//  VideoFace
//
//  Created by Marco Rossi on 09/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

class NoConnectionView: UIView {
    @IBOutlet weak var label: UILabel!
    let tapGestureRecognizer = UITapGestureRecognizer()
    
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
        
        let localizedContent = NSLocalizedString("No_connection", comment: "")
        label.text = localizedContent
    }
    
}
