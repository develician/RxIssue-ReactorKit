//
//  PostIssueViewController.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import RxKeyboard

class PostIssueViewController: BaseViewController, View {
    typealias Reactor = PostIssueViewReactor
    
    init(reactor: Reactor, owner: String, repo: String) {
        super.init()
        self.reactor = reactor
        self.owner = owner
        self.repo = repo
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: nil, action: nil)
    let saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: nil, action: nil)
    
    var owner: String?
    var repo: String?
    
    let titleField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.placeholder = "Write Your Issue's Title"
    }
    
    let issueTextView = UITextView().then {
        $0.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        $0.layer.borderWidth = 1.0
        $0.clipsToBounds = true
        $0.text = "Write Your Issue Here..."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Post New Issue"
        self.view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.saveButton
        
        self.view.addSubview(self.titleField)
        self.view.addSubview(self.issueTextView)
        
        self.prepareKeyboardUp()
    }
    
    override func setupConstraints() {
        self.titleField.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        self.issueTextView.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleField.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func bind(reactor: Reactor) {
        
        self.cancelButton.rx.tap.map { Reactor.Action.setDismiss }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.titleField.rx.text.flatMap { (title: String?) -> Observable<String> in
            guard let title = title else { return .empty() }
            return Observable.just(title)
        }.map(Reactor.Action.updateTitle)
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
        
        self.issueTextView.rx.text.flatMap { (content: String?) -> Observable<String> in
            guard let content = content else { return .empty() }
            return Observable.just(content)
            }.map(Reactor.Action.updateContent)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.saveButton.rx.tap.flatMap { [weak self] _ -> Observable<(String, String)> in
            guard let repo = self?.repo, let owner = self?.owner else { return .empty() }
            return Observable.just((repo, owner))
            }.map { (repo, owner) -> Reactor.Action in
                let title = reactor.currentState.title
                let body = reactor.currentState.content
                return Reactor.Action.postIssue(owner: owner, repo: repo, title: title, body: body)
        }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isDismissed }
            .distinctUntilChanged()
            .filter { (isDismissed) -> Bool in
                return isDismissed
            }.subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.title }
            .distinctUntilChanged()
            .bind(to: self.titleField.rx.text)
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.content }
            .distinctUntilChanged()
            .bind(to: self.issueTextView.rx.text)
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.newIssuePosted }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let newIssue = reactor.currentState.newIssue else { return }
                NotificationCenter.default.post(name: NSNotification.Name.NewIssuePosted, object: nil, userInfo: [
                    "newIssue": newIssue
                    ])
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
    }
    
    
    fileprivate func prepareKeyboardUp() {
        view.registerAutomaticKeyboardConstraints()
        
        self.issueTextView.snp.prepareConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            RxKeyboard.instance.visibleHeight.drive(onNext: { (keyboardVisibleHeight) in
                make.bottom.equalToSuperview().offset(-(keyboardVisibleHeight + 16)).keyboard(true, in: self.view)
            }).disposed(by: self.disposeBag)
        }

    }
    
}
