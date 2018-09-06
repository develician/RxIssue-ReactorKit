//
//  CommentsCell.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then


class CommentsCell: BaseCollectionViewCell, View {
    typealias Reactor = CommentsCellReactor
    
    struct Metric {
        static let cellPadding = 15.f
        static let profileImageBound = 44.f
        static let descLabelHeight = 32
    }
    
    struct Constant {
        static let descLabelNumberOfLines = 2
        static let bodyLabelNumberOfLines = 0
    }
    
    struct Color {
        static let descLabelText = UIColor.darkGray
        static let descLabelBackground = UIColor.groupTableViewBackground
        static let bodyLabelText = UIColor.black
        static let bodyLabelBackground = UIColor.white
        static let bodyLabelBorder = UIColor.groupTableViewBackground
    }
    
    struct Font {
        static let descLabel = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        static let bodyLabel = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
    }
    
    let profileImage = UIImageView().then {
        $0.backgroundColor = UIColor.groupTableViewBackground
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Metric.profileImageBound / 2
    }
    
    let descLabel = UILabel().then {
        $0.textColor = Color.descLabelText
        $0.backgroundColor = Color.descLabelBackground
        $0.font = Font.descLabel
        $0.numberOfLines = Constant.descLabelNumberOfLines
    }
    
    let descView = UIView().then {
        $0.backgroundColor = Color.descLabelBackground
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
        self.contentView.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initialize() {
        self.contentView.addSubview(self.profileImage)
        self.descView.addSubview(self.descLabel)
        self.contentView.addSubview(self.descView)
        self.bodyView.addSubview(self.bodyLabel)
        self.contentView.addSubview(self.bodyView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.profileImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Metric.cellPadding)
            make.left.equalToSuperview().offset(Metric.cellPadding)
            make.height.equalTo(Metric.profileImageBound)
            make.width.equalTo(Metric.profileImageBound)
        }
        
        self.descLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(Metric.cellPadding)
        }
        
        self.descView.snp.makeConstraints { (make) in
            make.top.equalTo(self.profileImage.snp.top)
            make.left.equalTo(self.profileImage.snp.right).offset(Metric.cellPadding)
            make.right.equalToSuperview().offset(-Metric.cellPadding)
            make.height.equalTo(Metric.descLabelHeight)
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
        guard let url = reactor.currentState.user.avatarURL else { return }
        self.profileImage.kf.setImage(with: url)
        
        let currentState = reactor.currentState
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let createdAt = currentState.createdAt else { return }
        let date = dateFormatter.string(from: createdAt)
        let username = currentState.user.login
        let desc = "\(username) commented on \(date)"
        
        self.descLabel.text = desc
        
        self.bodyLabel.text = currentState.body
    }
    
    class func heightForDescLabel(fits width: CGFloat, reactor: Reactor) -> CGFloat {
        let currentState = reactor.currentState
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let createdAt = currentState.createdAt else { return 0 }
        let date = dateFormatter.string(from: createdAt)
        let username = currentState.user.login
        let desc = "\(username) commented on \(date)"
        let height =  desc.height(
            fits: width - Metric.profileImageBound - Metric.cellPadding * 3,
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
