//
//  RepoViewController.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxViewController

class RepoViewController: BaseViewController, View {
    
    
    let provider: ServiceProviderType = ServiceProvider()
    
    let logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    let historyButton: UIBarButtonItem = UIBarButtonItem(title: "History", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    
    let ownerField = UITextField().then { (tf) in
        tf.borderStyle = .roundedRect
        tf.placeholder = "Please Type Owner Name"
        tf.font = UIFont.systemFont(ofSize: 18)
    }
    
    let repoField = UITextField().then { (tf) in
        tf.borderStyle = .roundedRect
        tf.placeholder = "Please Type Repository Name"
        tf.font = UIFont.systemFont(ofSize: 18)
    }
    
    lazy var fieldStackView = UIStackView(arrangedSubviews: [self.ownerField, self.repoField]).then { (sv) in
        sv.alignment = .fill
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 18
    }
    
    let enterButton = UIButton(type: .system).then {
        $0.setTitle("Find", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20)
    }
    
    init(reactor: Reactor) {
        super.init()
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    typealias Reactor = RepoViewReactor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = self.logoutButton
        self.navigationItem.rightBarButtonItem = self.historyButton
        
        self.view.addSubview(self.fieldStackView)
        self.view.addSubview(self.enterButton)
        self.fieldStackView.arrangedSubviews[0].becomeFirstResponder()
        
    }
    
    
    override func setupConstraints() {
        self.fieldStackView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(16)
            make.left.equalTo(self.view.snp.left).offset(16)
            make.right.equalTo(self.view.snp.right).offset(-16)
            make.height.equalTo(self.view.snp.height).dividedBy(8)
        }
        
        self.enterButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.fieldStackView.snp.bottom).offset(16)
            make.centerX.equalTo(self.fieldStackView.snp.centerX)
            
        }
    }
    
    func bind(reactor: Reactor) {
        
        self.rx.viewDidLoad.map { Reactor.Action.getUserInfo }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.logoutButton.rx.tap.map { Reactor.Action.logout }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.ownerField.rx.text
            .flatMap { (owner) -> Observable<String> in
                guard let owner = owner else { return Observable.empty() }
                return Observable.just(owner)
            }.map(Reactor.Action.updateOwner).bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.repoField.rx.text
            .flatMap { (repo) -> Observable<String> in
                guard let repo = repo else { return Observable.empty() }
                return Observable.just(repo)
            }.map(Reactor.Action.updateRepo).bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.enterButton.rx.tap.filter { [weak self] _ -> Bool in
            let owner = reactor.currentState.owner
            let repo = reactor.currentState.repo
            
            if owner.isEmpty || repo.isEmpty {
                let alert = UIAlertController(title: "모든 항목을 입력해주세요", message: "오류", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                return false
            } else {
                return true
            }
            }.subscribe(onNext: { [weak self] _ in
                let owner = reactor.currentState.owner
                let repo = reactor.currentState.repo
                
                self?.provider.repoService.addHistory(owner: owner, repo: repo)
                self?.provider.repoService.setLastRepo(owner: owner, repo: repo)
                
                let githubService = GithubService()
                let reactor = IssuesViewReactor(githubService: githubService)
                let issuesView = IssuesViewController(reactor: reactor, owner: owner, repo: repo)
                self?.navigationController?.pushViewController(issuesView, animated: true)
            }).disposed(by: self.disposeBag)
        
        self.historyButton.rx.tap.subscribe(onNext: { [weak self] _ in
            let provider = ServiceProvider()
            let reactor = HistoryViewReactor(provider: provider)
            let historyView = HistoryViewController(reactor: reactor)
            let historyNavi = UINavigationController(rootViewController: historyView)
            historyView.title = "Search Histories"
            self?.present(historyNavi, animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
        
        reactor.state.map { $0.showLoginView }
            .filter { showLoginView -> Bool in
                return showLoginView
            }.subscribe(onNext: { [weak self] _ in
                let provider = ServiceProvider()
                let service = GithubService()
                let reactor = LoginViewReactor(provider: provider, githubService: service)
                let loginView = LoginViewController(reactor: reactor)
                self?.provider.appService.delegate.window?.rootViewController?.present(loginView, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.owner }
            .distinctUntilChanged()
            .bind(to: self.ownerField.rx.text)
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.repo }
            .distinctUntilChanged()
            .bind(to: self.repoField.rx.text)
            .disposed(by: self.disposeBag)
    }
    
}

















