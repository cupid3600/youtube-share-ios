//
//  UIViewController+StoryboardInstantiatable.swift
//  VideoFace
//
//  Created by Marco Rossi on 09/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

protocol StoryboardInstantiatable {
    static var StoryboardName: String { get }
}

extension StoryboardInstantiatable {
    
    static var StoryboardName: String { return String(describing: self) }
    
    static func instantiate() -> Self {
        return instantiateWithName(name: StoryboardName)
    }
    
    static func instantiateWithName(name: String) -> Self {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? Self else{
            fatalError("failed to load \(name) storyboard file.")
        }
        return vc
    }
}
