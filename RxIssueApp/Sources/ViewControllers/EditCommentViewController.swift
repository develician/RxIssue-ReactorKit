//
//  EditCommentViewController.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 11..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import Then
import SnapKit
import RxKeyboard

class EditCommentViewController: BaseViewController, View {
    typealias Reactor = EditCommentViewReactor
    
    var comment: Model.Comment?
    
    let commentTextView = UITextView().then {
        $0.clipsToBounds = true
        $0.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        $0.layer.borderWidth = 1.0
    }
    
    init(reactor: Reactor, comment: Model.Comment, owner: String, repo: String) {
        super.init()
        self.reactor = reactor
        self.comment = comment
        self.owner = owner
        self.repo = repo
    }
    
    var owner: String?
    var repo: String?
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.title = "Edit Your Comment"
        
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.doneButton
        
        self.view.addSubview(self.commentTextView)
        guard let comment = comment else { return }
        self.commentTextView.text = comment.body
        self.prepareKeyboardUp()
    }

    override func setupConstraints() {
        guard let navBar = self.navigationController?.navigationBar else { return }
        let navBarHeight = navBar.frame.height
        self.commentTextView.snp.makeConstraints { (make) in
            
            make.top.equalToSuperview().offset(navBarHeight + 16)
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.right.equalToSuperview().offset(-8)
        }
    }
    
    func bind(reactor: Reactor) {
        self.cancelButton.rx.tap.map { Reactor.Action.dismiss }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.doneButton.rx.tap
            .flatMap({ [weak self] _ -> Observable<(String, String, Int, String)> in
                guard let owner = self?.owner, let repo = self?.repo else { return .empty() }
                guard let commentId = self?.comment?.id else { return .empty() }
                let comment = reactor.currentState.comment
                return Observable.just((owner, repo, commentId, comment))
            })
            .map { (owner, repo, commentId, comment) -> Reactor.Action in
            return Reactor.Action.editComment(owner: owner, repo: repo, commentId: commentId, body: comment)
        }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.commentTextView.rx.text
            .flatMap { (text) -> Observable<String> in
                guard let text = text else { return .empty() }
                return Observable.just(text)
        }.map(Reactor.Action.updateComment).bind(to: reactor.action)
        .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isDismissed }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.comment }
            .bind(to: self.commentTextView.rx.text)
            .disposed(by: self.disposeBag)
    }
    
    private func prepareKeyboardUp() {
        self.view.registerAutomaticKeyboardConstraints()
        
        self.commentTextView.snp.prepareConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            RxKeyboard.instance.visibleHeight.drive(onNext: { (keyboardVisibleHeight) in
                make.bottom.equalToSuperview().offset(-(keyboardVisibleHeight + 8)).keyboard(true, in: self.view)
            }).disposed(by: self.disposeBag)
        }
    }
    

}
