//
//  EmotionBottomSheet.swift
//  VideoFace
//
//  Created by Marco Rossi on 18/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

class EmotionTableViewMenu: UITableViewController, BindableType {
    
    // MARK: ViewModel
    var viewModel: EmotionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerCell(type: EmotionCell.self)
        tableView.rowHeight = 50
        tableView.allowsMultipleSelection = true
        tableView.separatorStyle = .none
    }
    
    func bindViewModel() {
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
    }
}
