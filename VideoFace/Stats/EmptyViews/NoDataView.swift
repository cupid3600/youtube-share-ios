//
//  NoDataView.swift
//  VideoFace
//
//  Created by Marco Rossi on 09/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

class NoDataView: UIView {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let localizedContent = NSLocalizedString("No_data", comment: "")
        label.text = localizedContent
    }
}
