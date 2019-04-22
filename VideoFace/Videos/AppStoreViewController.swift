//
//  AppStoreViewController.swift
//  VideoFace
//
//  Created by Marco Rossi on 26/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import StoreKit

class AppStoreViewController: UIViewController {
    fileprivate let storeViewController: SKStoreProductViewController
    fileprivate var identifier: String
    
    init(with identifier: String) {
        self.identifier = identifier
        self.storeViewController = SKStoreProductViewController()
        
        super.init(nibName: nil, bundle: nil)
    
        storeViewController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        add(storeViewController)
        
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                
            }
        }
    }
    
    func add(_ child: UIViewController) {
        addChildViewController(child)
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
    }
}

extension AppStoreViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
//        viewController.dismiss(animated: true, completion: nil)
        SceneCoordinator.shared.pop(animated: true)
    }
}
