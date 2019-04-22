//
//  LoadingView.swift
//  Papr
//
//  Created by Joan Disho on 18.09.18.
//  Copyright © 2018 Joan Disho. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class LoadingView: UIView {

    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        self.addSubview(activityIndicatorView)
        
        activityIndicatorView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.center.equalToSuperview()
        }

        activityIndicatorView.startAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func stopAnimating() {
        activityIndicatorView.stopAnimating()
        isHidden = true
    }
}
