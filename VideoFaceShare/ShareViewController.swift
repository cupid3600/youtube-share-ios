//
//  ShareViewController.swift
//  VideoFaceShare
//
//  Created by Marco Rossi on 03/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancel = "cancel".localized()
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = cancel
        let share = "share".localized()
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = share
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func isContentValid() -> Bool {
        if let youtubeID = contentText.youtubeID, youtubeID.count == 11 {
            return true
        }
        return false
    }

    override func didSelectPost() {
        redirectToHostApp()
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func redirectToHostApp() {
        var components = URLComponents()
        components.scheme = "videoface"
        components.host = "share"
        
        let queryItemUrl = URLQueryItem(name: "videoURL", value: contentText)
        components.queryItems = [queryItemUrl]

        let url = components.url
        
        _ = openURL(url!)
        
//        var responder = self as UIResponder?
//        let selectorOpenURL = sel_registerName("openURL:")
//
//        while (responder != nil) {
//            if (responder?.responds(to: selectorOpenURL))! {
//                let _ = responder?.perform(selectorOpenURL, with: url)
//            }
//            responder = responder!.next
//        }
    }
    
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }

    override func configurationItems() -> [Any]! {
        return []
    }

}

extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        
        guard let result = regex?.firstMatch(in: self, options: [], range: range) else {
            return nil
        }
        
        return (self as NSString).substring(with: result.range)
    }
}
