//
//  BaseFooterView.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit

import RxSwift

class BaseReusableView: UICollectionReusableView {
    
    // MARK: Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    
    // MARK: Initializing
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() {
        // Override point
    }
    
}
