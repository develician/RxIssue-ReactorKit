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
    
    let service: ServiceProviderType = ServiceProvider()
    
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
    let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var owner: String?
    var repo: String?
    var comment: Model.Comment?
    
    struct PlaceHolders {
        static let titleField = "Write Your Issue's Title"
        static let issueTextView = "Write Your Issue Here..."
    }
    
    let titleField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.placeholder = PlaceHolders.titleField
    }
    
    let issueTextView = UITextView().then {
        $0.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        $0.layer.borderWidth = 1.0
        $0.clipsToBounds = true
        $0.text = PlaceHolders.issueTextView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Post New Issue"
        self.view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.saveButton
        
        self.view.addSubview(self.titleField)
        self.view.addSubview(self.issueTextView)
        self.view.addSubview(self.activityIndicatorView)
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
        
        self.activityIndicatorView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.activityIndicatorView.layer.backgroundColor = UIColor.black.withAlphaComponent(0.3).cgColor
    }
    
    func bind(reactor: Reactor) {
        
        self.issueTextView.rx.setDelegate(self).disposed(by: self.disposeBag)
        
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
        
        self.saveButton.rx.tap
            .filter({ [weak self] _ -> Bool in
                if reactor.currentState.title.isEmpty || reactor.currentState.content.isEmpty {
                    let alert = UIAlertController(title: "Please fill your issues..", message: "Fill Your Fields.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                    return false
                }
                return true
            })
            .flatMap { [weak self] _ -> Observable<(String, String)> in
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
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isLoading }
            .bind(to: self.activityIndicatorView.rx.isAnimating)
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

extension PostIssueViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == PlaceHolders.issueTextView {
            textView.text = ""
        }
    }
}






