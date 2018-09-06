//
//  HistoryViewController.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import ReactorKit
import Then
import ReusableKit
import SnapKit
import RxViewController
import RxSwift

class HistoryViewController: BaseViewController, View {
    typealias Reactor = HistoryViewReactor

    let provider: ServiceProviderType = ServiceProvider()
    
    
    struct Reusable {
        static let historyCell: ReusableCell<UITableViewCell> = ReusableCell<UITableViewCell>()
    }
    
    let tableView = UITableView(frame: .zero, style: UITableViewStyle.plain).then {
        $0.register(Reusable.historyCell)
        $0.backgroundColor = .white
        
    }
    
    let closeButton: UIBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    
    init(reactor: Reactor) {
        super.init()
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = self.closeButton
        self.view.addSubview(self.tableView)
        
    }
    
    override func setupConstraints() {
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    func bind(reactor: Reactor) {
        self.rx.viewDidLoad.map { Reactor.Action.setHistories }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.closeButton.rx.tap.map { Reactor.Action.setDismiss }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemSelected.map { (indexPath) -> Reactor.Action in
            let selectedHistory = reactor.currentState.sections[indexPath.section].items[indexPath.item]
            return Reactor.Action.setSelected(selectedHistory)
            }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        
        reactor.state.map { $0.sections }
            .bind(to: self.tableView.rx.items(dataSource: self.createDataSource()))
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isDismissed }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.selectedRepo }
            .flatMap { (repo) -> Observable<Bool> in
                if let _ = repo {
                    return Observable.just(true)
                } else{
                    return Observable.just(false)
                }
            }.subscribe(onNext: { [weak self] isSelected in
                if isSelected {
                    guard let appDelegate = self?.provider.appService.delegate else { return }
                    guard let rootNavi = appDelegate.window?.rootViewController as? UINavigationController else { return }
                    guard let selectedRepo = reactor.currentState.selectedRepo else { return }
                    
                    let githubService = GithubService()
                    let reactor = IssuesViewReactor(githubService: githubService)
                    let issuesView = IssuesViewController(reactor: reactor, owner: selectedRepo.owner, repo: selectedRepo.repo)
                    rootNavi.pushViewController(issuesView, animated: true)
                }
            }).disposed(by: self.disposeBag)
    }
    
    func createDataSource() -> HistoryDataSourceType {
        return HistoryDataSourceType(configureCell: { (dataSource, tableView, indexPath, repo) -> UITableViewCell in
            let cell = tableView.dequeue(Reusable.historyCell) ?? UITableViewCell()
            cell.textLabel?.text = "\(repo.owner)/\(repo.repo)"
            return cell
        })
    }
    

}
