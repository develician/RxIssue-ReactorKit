//
//  IssuesViewController.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxViewController
import ReusableKit

class IssuesViewController: BaseViewController, View {
    typealias Reactor = IssuesViewReactor

    
    var owner: String!
    var repo: String!
    
    struct Reusable {
        static let issueCell = ReusableCell<IssueCell>()
        static let loadMoreCell = ReusableView<LoadMoreCell>()
    }
    
    let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout).then {
        $0.backgroundColor = .white
        $0.register(Reusable.issueCell)
        $0.register(Reusable.loadMoreCell, kind: SupplementaryViewKind.footer)
    }
    
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: nil, action: nil)
    
    init(reactor: Reactor, owner: String, repo: String) {
        super.init()
        self.owner = owner
        self.repo = repo
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        guard let owner = self.owner, let repo = self.repo else { return }
        self.title = "\(owner)/\(repo)"
        self.navigationItem.rightBarButtonItem = self.addButton
        self.view.addSubview(self.collectionView)
        
        self.collectionView.refreshControl = self.refreshControl
    }
    
    override func setupConstraints() {
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
    }
    
    func bind(reactor: Reactor) {

        
        self.collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
        
        self.rx.viewDidLoad.map { [weak self] _ -> Reactor.Action in
            guard let owner = self?.owner, let repo = self?.repo else { return Reactor.Action.refresh(owner: "", repo: "") }
            return Reactor.Action.refresh(owner: owner, repo: repo)
        }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.collectionView.rx.isReachedBottom.map { [weak self] _ -> Reactor.Action in
            guard let owner = self?.owner, let repo = self?.repo else { return Reactor.Action.refresh(owner: "", repo: "") }
            return Reactor.Action.loadMore(owner: owner, repo: repo)
        }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .map { [weak self] _ -> Reactor.Action in
                guard let owner = self?.owner, let repo = self?.repo else { return Reactor.Action.refresh(owner: "", repo: "") }
                return Reactor.Action.refresh(owner: owner, repo: repo)
        }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.addButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let repo = self?.repo, let owner = self?.owner else { return }
            let githubService = reactor.githubService
            let reactor = PostIssueViewReactor(githubService: githubService)
            let postIssueView = PostIssueViewController(reactor: reactor, owner: owner, repo: repo)
            let postIssueNavi = UINavigationController(rootViewController: postIssueView)
            self?.present(postIssueNavi, animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
        
        self.collectionView.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] (indexPath) in
            guard let owner = self?.owner, let repo = self?.repo else { return }
            let issue = reactor.currentState.sections[indexPath.section].items[indexPath.item].initialState
            guard let githubService = self?.reactor?.githubService else { return }
            let reactor = CommentsViewReactor(githubService: githubService)
            let commentView = CommentsViewController(reactor: reactor, owner: owner, repo: repo, issue: issue, indexPath: indexPath)
            self?.navigationController?.pushViewController(commentView, animated: true)
        }).disposed(by: self.disposeBag)
        
        reactor.state.map { $0.sections }
            .bind(to: self.collectionView.rx.items(dataSource: self.createDataSource()))
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: self.disposeBag)
        
    }
    
    func createDataSource() -> IssueDataSourceType {
        return IssueDataSourceType(configureCell: { (dataSource, collectionView, indexPath, reactor) -> UICollectionViewCell in
            let cell = collectionView.dequeue(Reusable.issueCell, for: indexPath)
            cell.reactor = reactor
            return cell
        }, configureSupplementaryView: { [weak self] (dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
            switch kind {
            case UICollectionElementKindSectionFooter:
                let footerView = collectionView.dequeue(Reusable.loadMoreCell, kind: kind, for: indexPath)
                guard let isLastPage = self?.reactor?.currentState.reachedLastPage else { return UICollectionReusableView() }
                guard let sectionItems = self?.reactor?.currentState.sections[indexPath.section].items else { return UICollectionReusableView() }
                if sectionItems.count < 30 {
                    return footerView
                }
                if isLastPage {
                    footerView.reactor = LoadMoreCellReactor(isAnimating: false)
                } else {
                    footerView.reactor = LoadMoreCellReactor(isAnimating: true)
                }
                return footerView
            default:
                return UICollectionReusableView()
            }
        })
    }

}

extension IssuesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sections = self.reactor?.currentState.sections else { return CGSize(width: 0, height: 0) }
        let reactor = sections[indexPath.section].items[indexPath.item]
        let titleHeight = IssueCell.heightForTitleLabel(fits: collectionView.frame.size.width, reactor: reactor)
        let descHeight = IssueCell.heightForDescLabel(fits: collectionView.frame.size.width, reactor: reactor)
        return CGSize(width: collectionView.frame.size.width, height: titleHeight + descHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }
}












