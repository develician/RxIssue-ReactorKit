//
//  IssueCell.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import Then
import SnapKit
import ReactorKit
import CGFloatLiteral

class IssueCell: BaseCollectionViewCell, View {
    typealias Reactor = IssueCellReactor
    
    struct Constant {
        static let titleLabelNumberOfLines = 0
    }
    
    struct Metric {
        static let cellPadding = 15.f
        static let issueStateViewBound = 25.f
        static let separatorViewHeight = 1.f
        static let commentsButtonViewBound = 35.f
    }
    
    struct Font {
        static let titleLabelFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        static let descLabelFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
    }
    
    let issueStateView = UIImageView().then {
        $0.backgroundColor = .white
    }
    
    let separatorView = UIView().then {
        $0.backgroundColor = UIColor.groupTableViewBackground
    }
    
    let titleLabel = UILabel().then {
        $0.font = Font.titleLabelFont
        $0.numberOfLines = Constant.titleLabelNumberOfLines
        $0.sizeToFit()
    }
    
    let commentsButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "ic_comment"), for: UIControlState.normal)
        $0.tintColor = UIColor.lightGray
    }
    
    let descLabel = UILabel().then {
        $0.font = Font.descLabelFont
        $0.textColor = UIColor.lightGray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        
    }
    
    override func initialize() {
        self.contentView.addSubview(self.issueStateView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.commentsButton)
        self.contentView.addSubview(self.descLabel)
        self.contentView.addSubview(self.separatorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.issueStateView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Metric.cellPadding)
            make.left.equalToSuperview().offset(Metric.cellPadding)
            make.width.equalTo(Metric.issueStateViewBound)
            make.height.equalTo(Metric.issueStateViewBound)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Metric.cellPadding)
            make.right.equalTo(self.commentsButton.snp.left)
            make.left.equalTo(self.issueStateView.snp.right).offset(Metric.cellPadding)
        }
        
        self.commentsButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Metric.cellPadding)
            make.left.equalTo(self.titleLabel.snp.right).offset(Metric.cellPadding)
            make.right.equalToSuperview().offset(-Metric.cellPadding)
            make.width.equalTo(Metric.commentsButtonViewBound)
        }
        
        self.descLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.separatorView.snp.top).offset(-Metric.cellPadding)
            make.left.equalTo(self.separatorView.snp.left)
        }
        self.separatorView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalTo(self.titleLabel.snp.left)
            make.right.equalToSuperview()
            make.height.equalTo(Metric.separatorViewHeight)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: Reactor) {
        let currentState = reactor.currentState
        
        self.issueStateView.image = currentState.state == .open ? UIImage(named: "ic_issues_open") : UIImage(named: "ic_issues_closed")
        self.titleLabel.text = currentState.title
        self.commentsButton.setTitle("\(currentState.comments)", for: .normal)
        self.commentsButton.isHidden = currentState.comments == 0
        
        
        let number = currentState.number
        let state = currentState.state.rawValue
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = currentState.createdAt else { return }
        let dateString = dateFormatter.string(from: date)
        let writer = currentState.user.login
        self.descLabel.text = "#\(number) \(state) \(dateString) by \(writer)"
    }
    
    class func heightForTitleLabel(fits width: CGFloat, reactor: Reactor) -> CGFloat {
        let height =  reactor.currentState.title.height(
            fits: width - Metric.cellPadding * 3 + Metric.issueStateViewBound,
            font: Font.titleLabelFont,
            maximumNumberOfLines: Constant.titleLabelNumberOfLines
        )
        return height + Metric.cellPadding * 2
    }
    
    class func heightForDescLabel(fits width: CGFloat, reactor: Reactor) -> CGFloat {
        let currentState = reactor.currentState
        let number = currentState.number
        let state = currentState.state.rawValue
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = currentState.createdAt else { return 0.f }
        let dateString = dateFormatter.string(from: date)
        let writer = currentState.user.login
        let height =  "#\(number) \(state) \(dateString) by \(writer)".height(
            fits: width - Metric.cellPadding * 2,
            font: Font.descLabelFont,
            maximumNumberOfLines: 1
        )
        return height + Metric.cellPadding * 2
    }
    
    
}
