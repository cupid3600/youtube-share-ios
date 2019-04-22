//
//  EmotionViewModel.swift
//  VideoFace
//
//  Created by Marco Rossi on 18/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import UIKit

class EmotionItem {
    let emotion: Emotion
    
    var isSelected: Bool
    
    var title: String {
        return emotion.description
    }
    
    var color: UIColor {
        return emotion.color
    }
    
    init(emotion: Emotion, selected: Bool = false) {
        self.emotion = emotion
        self.isSelected = selected
    }
}

class EmotionViewModel: NSObject {
    private let items: [EmotionItem]
    
    var didToggleSelection: ((_ hasSelection: Bool) -> ())? {
        didSet {
            didToggleSelection?(!selectedItems.isEmpty)
        }
    }
    
    var selectedItems: [EmotionItem] {
        return items.filter { return $0.isSelected }
    }
    
    init(items: [EmotionItem]) {
        self.items = items
    }
}

extension EmotionViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: EmotionCell.self, at: indexPath)
        cell.item = items[indexPath.row]
        
        // select/deselect the cell
        if items[indexPath.row].isSelected {
            if !cell.isSelected {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        } else {
            if cell.isSelected {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
//        return view
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 100
//    }
}

extension EmotionViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // update ViewModel item
        items[indexPath.row].isSelected = true
        
        didToggleSelection?(!selectedItems.isEmpty)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        // update ViewModel item
        items[indexPath.row].isSelected = false
        
        didToggleSelection?(!selectedItems.isEmpty)
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if selectedItems.count == 1 {
            return nil
        }
        return indexPath
    }
}
