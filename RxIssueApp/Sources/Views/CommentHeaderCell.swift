//
//  CommentHeaderCell.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import ReactorKit
import Then
import SnapKit
import CGFloatLiteral

class CommentHeaderCell: BaseReusableView, View {
    typealias Reactor = CommentHeaderCellReactor
    
    struct Constant {
        static let titleLabelNumberOfLines = 0
        static let descLabelNumberOfLines = 2
        
        static let bodyDescLabelNumberOfLines = 2
        static let bodyLabelNumberOfLines = 0
    }
    
    struct Metric {
        static let cellPadding = 15.f
        static let stateButtonWidth = 70.f
        static let stateButtonHeight = 30.f
        static let profileImageBound = 44.f
       
        static let bodyDescLabelHeight = 32
    }
    
    struct Font {
        static let titleLabel = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
        static let descLabel = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        
        static let bodyDescLabel = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        static let bodyLabel = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
    }
    
    struct Color {
        static let titleLabel = UIColor.darkGray
        static let stateButton = UIColor.white
        static let descLabel = UIColor.lightGray
        static let profileImage = UIColor.groupTableViewBackground
        
        static let bodyDescLabelText = UIColor.darkGray
        static let bodyDescLabelBackground = UIColor.groupTableViewBackground
        static let bodyLabelText = UIColor.black
        static let bodyLabelBackground = UIColor.white
        static let bodyLabelBorder = UIColor.groupTableViewBackground
        
    }
    
    let titleLabel = UILabel().then {
        $0.font = Font.titleLabel
        $0.textColor = Color.titleLabel
        $0.numberOfLines = Constant.titleLabelNumberOfLines
        $0.sizeToFit()
    }
    
    let stateButton = UIButton(type: .custom).then {
        $0.titleLabel?.textColor = Color.stateButton
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 3
    }
    
    let separatorView = UIView().then {
        $0.backgroundColor = UIColor.groupTableViewBackground
    }
    
    let descLabel = UILabel().then {
        $0.font = Font.descLabel
        $0.textColor = Color.descLabel
        $0.numberOfLines = Constant.descLabelNumberOfLines
        $0.sizeToFit()
    }
    
    let profileImage = UIImageView().then {
        $0.backgroundColor = Color.profileImage
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Metric.profileImageBound / 2
    }
    
    let bodyDescLabel = UILabel().then {
        $0.textColor = Color.bodyDescLabelText
        $0.backgroundColor = Color.bodyDescLabelBackground
        $0.font = Font.bodyDescLabel
        $0.numberOfLines = Constant.descLabelNumberOfLines
    }
    
    let descView = UIView().then {
        $0.backgroundColor = Color.bodyDescLabelBackground
    }
    
    let bodyLabel = UILabel().then {
        $0.backgroundColor = UIColor.white
        $0.textColor = Color.bodyLabelText
        $0.font = Font.bodyLabel
        $0.numberOfLines = 0
        $0.sizeToFit()
    }
    
    let bodyView = UIView().then {
        $0.backgroundColor = Color.bodyLabelBackground
        $0.layer.borderColor = Color.bodyLabelBorder.cgColor
        $0.layer.borderWidth = 1.0
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initialize() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.stateButton)
        self.addSubview(self.descLabel)
        self.addSubview(self.separatorView)
        self.addSubview(self.profileImage)
        
        self.descView.addSubview(self.bodyDescLabel)
        self.addSubview(self.descView)
        self.bodyView.addSubview(self.bodyLabel)
        self.addSubview(self.bodyView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Metric.cellPadding)
            make.left.equalToSuperview().offset(Metric.cellPadding)
            make.right.equalToSuperview().offset(-Metric.cellPadding)
        }
        
        self.stateButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(Metric.cellPadding)
            make.left.equalToSuperview().offset(Metric.cellPadding)
            make.width.equalTo(Metric.stateButtonWidth)
            make.height.equalTo(Metric.stateButtonHeight)
//            make.bottom.equalToSuperview().offset(-Metric.cellPadding)
        }
        
        self.descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.stateButton.snp.top)
            make.left.equalTo(self.stateButton.snp.right).offset(Metric.cellPadding)
            make.right.equalToSuperview().offset(-Metric.cellPadding)
//            make.bottom.equalToSuperview().offset(-Metric.cellPadding)
        }
        
        self.separatorView.snp.makeConstraints { (make) in
            make.top.equalTo(self.stateButton.snp.bottom).offset(Metric.cellPadding)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.profileImage.snp.makeConstraints { (make) in
            make.top.equalTo(self.separatorView.snp.bottom).offset(Metric.cellPadding)
            make.left.equalToSuperview().offset(Metric.cellPadding)
            make.height.equalTo(Metric.profileImageBound)
            make.width.equalTo(Metric.profileImageBound)
        }
        
        self.bodyDescLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(Metric.cellPadding)
        }
        
        self.descView.snp.makeConstraints { (make) in
            make.top.equalTo(self.profileImage.snp.top)
            make.left.equalTo(self.profileImage.snp.right).offset(Metric.cellPadding)
            make.right.equalToSuperview().offset(-Metric.cellPadding)
            make.height.equalTo(Metric.bodyDescLabelHeight)
        }
        
        self.bodyLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Metric.cellPadding)
            make.left.equalToSuperview().offset(Metric.cellPadding)
            make.right.equalToSuperview().offset(-Metric.cellPadding)
            make.bottom.equalToSuperview().offset(-Metric.cellPadding)
        }
        
        self.bodyView.snp.makeConstraints { (make) in
            make.top.equalTo(self.descView.snp.bottom)
            make.left.equalTo(self.descView.snp.left)
            make.right.equalTo(self.descView.snp.right)
            make.bottom.equalToSuperview().offset(-Metric.cellPadding)
        }
    }
    
    func bind(reactor: Reactor) {
        let currentState = reactor.currentState
        let title = currentState.title
        let state = currentState.state

        self.titleLabel.text = title
        self.stateButton.backgroundColor = state.color
        self.stateButton.setTitle("\(state.rawValue)", for: UIControlState.normal)

        let username = currentState.user.login
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let createdAt = currentState.createdAt else { return }
        let date = dateFormatter.string(from: createdAt)
        let commentsCount = currentState.comments
        let desc = "\(username) \(state.rawValue) this issue on \(date) \(commentsCount) comments"

        self.descLabel.text = desc

        guard let url = currentState.user.avatarURL else { return }
        self.profileImage.kf.setImage(with: url)

        self.bodyDescLabel.text = "\(username) commented on \(date)"
        self.bodyLabel.text = currentState.body
        
        self.stateButton.rx.tap.map { _ -> Reactor.Action in
            let issue = reactor.currentState
            print("toggle Issue")
            return Reactor.Action.toggleState(issue)
        }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        reactor.state.subscribe(onNext: { [weak self] (issue) in
            guard let `self` = self else { return }
            self.stateButton.backgroundColor = issue.state.color
            self.stateButton.setTitle("\(issue.state.rawValue)", for: UIControlState.normal)
        }).disposed(by: self.disposeBag)
        
    }
    
    func update() {
        
    }
    
    class func heightForTitleLabel(fits width: CGFloat, reactor: Reactor) -> CGFloat {
        let height =  reactor.currentState.title.height(
            fits: width - Metric.cellPadding * 2,
            font: Font.titleLabel,
            maximumNumberOfLines: Constant.titleLabelNumberOfLines
        )
        return height
    }
    
    class func heightForDescLabel(fits width: CGFloat, reactor: Reactor) -> CGFloat {
        let currentState = reactor.currentState
        let username = currentState.user.login
        let state = currentState.state.rawValue
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let createdAt = currentState.createdAt else { return 0 }
        let date = dateFormatter.string(from: createdAt)
        let commentsCount = currentState.comments
        let desc = "\(username) \(state) this issue on \(date) \(commentsCount) comments"
        let height =  desc.height(
            fits: width - Metric.stateButtonWidth - Metric.cellPadding * 2,
            font: Font.descLabel,
            maximumNumberOfLines: Constant.descLabelNumberOfLines
        )
        return height
    }
    
    class func heightForBodyLabel(fits width: CGFloat, reactor: Reactor) -> CGFloat {
        let height =  reactor.currentState.body.height(
            fits: width - Metric.profileImageBound - Metric.cellPadding * 5,
            font: Font.bodyLabel,
            maximumNumberOfLines: Constant.bodyLabelNumberOfLines
        )
        return height + Metric.cellPadding * 2
    }
}










