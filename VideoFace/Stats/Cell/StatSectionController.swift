//
//  StatSectionController.swift
//  VideoFace
//
//  Created by Marco Rossi on 10/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import IGListKit

final class StatSectionController: ListSectionController {
    var model: StatSection?
    
    override init() {
        super.init()
        self.minimumLineSpacing = 10
    }
    
    // MARK: ListSectionController
    
    override func numberOfItems() -> Int {
        return model?.viewModels.count ?? 0
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext!.containerSize.height
        return CGSize(width: 40, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let nibName = String(describing: StatViewCell.self)
        guard let context = collectionContext, let viewModel = model?.viewModels[index],
            var cell = context.dequeueReusableCell(withNibName: nibName, bundle: nil, for: self, at: index) as? StatViewCell else {
                return UICollectionViewCell()
        }
        cell.bind(to: viewModel)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        model = object as? StatSection
        let cellCount = numberOfItems()
        if cellCount > 0 {
            let contentSpace = (CGFloat(cellCount) * 40) + (CGFloat(cellCount - 1) * self.minimumLineSpacing)
            let availableSpace = collectionContext!.containerSize.width - contentSpace
            inset = UIEdgeInsets(top: 0, left: availableSpace * 0.5, bottom: 0, right: availableSpace * 0.5)
        }
    }
}
