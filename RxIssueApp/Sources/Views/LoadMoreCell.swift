//
//  LoadMoreCell.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

class LoadMoreCell: BaseReusableView, View {
    typealias Reactor = LoadMoreCellReactor
    
    let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.activityIndicatorView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    override func initialize() {
        self.addSubview(self.activityIndicatorView)
    }
    
    
    func bind(reactor: Reactor) {
        if reactor.currentState {
            self.activityIndicatorView.startAnimating()
        } else {
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
