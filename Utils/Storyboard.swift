//
//  Storyboard.swift
//  VideoFace
//
//  Created by Marco Rossi on 09/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit

public enum Storyboard: String {
    case Stats
    
    public func instantiate<VC: UIViewController>(_ viewController: VC.Type,
                                                  inBundle bundle: Bundle = .main) -> VC {
        guard
            let vc = UIStoryboard(name: self.rawValue, bundle: Bundle(identifier: bundle.identifier))
                .instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC
            else { fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)") }
        
        return vc
    }
}
