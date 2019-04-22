//
//  LoadingView.swift
//  Example
//
//  Created by Alexander Schuch on 29/08/14.
//  Copyright (c) 2014 Alexander Schuch. All rights reserved.
//

import UIKit
import StatefulViewController
import SnapKit

import MaterialComponents.MDCActivityIndicator

class LoadingView: BasicPlaceholderView, StatefulPlaceholderView {
	
	override func setupView() {
		super.setupView()
        
        let activityIndicator = MDCActivityIndicator()
        activityIndicator.radius = 38
        activityIndicator.strokeWidth = 5
        activityIndicator.cycleColors = [.lightGray]
        activityIndicator.sizeToFit()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(activityIndicator)
    
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        // To make the activity indicator appear:
        activityIndicator.startAnimating()
	}

    func placeholderViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

}
