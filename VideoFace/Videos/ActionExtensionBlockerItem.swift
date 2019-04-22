//
//  ActionExtensionBlockerItem.swift
//  VideoFace
//
//  Created by Marco Rossi on 12/11/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

class ActionExtensionBlockerItem: NSObject, UIActivityItemSource {
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivityType?) -> String {
        return "com.cynny.videoface";
    }
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        // Returning an NSObject here is safest, because otherwise it is possible for the activity item to actually be shared!
        return NSObject()
    }
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return ""
    }
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return nil
    }
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
}
