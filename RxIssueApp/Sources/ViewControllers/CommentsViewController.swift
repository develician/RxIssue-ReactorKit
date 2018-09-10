//
//  CommentsViewController.swift
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
import ReusableKit
import RxViewController
import RxKeyboard

class CommentsViewController: BaseViewController, View {
    typealias Reactor = CommentsViewReactor

    var owner: String!
    var repo: String!
    var issue: Model.Issue!
    var indexPath: IndexPath!
    
    init(reactor: Reactor, owner: String, repo: String, issue: Model.Issue, indexPath: IndexPath) {
        super.init()
        self.reactor = reactor
        self.owner = owner
        self.repo = repo
        self.issue = issue
        self.indexPath = indexPath
    }
    
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Reusable {
        static let headerCell = ReusableView<CommentHeaderCell>()
        static let commentCell = ReusableCell<CommentsCell>()
        static let loadMoreCell = ReusableView<LoadMoreCell>()
    }
    
    let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout).then {
        $0.backgroundColor = .white
        $0.register(Reusable.headerCell, kind: SupplementaryViewKind.header)
        $0.register(Reusable.commentCell)
        $0.register(Reusable.loadMoreCell, kind: SupplementaryViewKind.footer)
        $0.keyboardDismissMode = .interactive
    }
    
    let inputField = UITextField().then {
        $0.borderStyle = .roundedRect
    }
    
    let sendButton = UIButton(type: .system).then {
        $0.setTitle("Send", for: UIControlState.normal)
    }
    
    let inputWrapper = UIView().then {
        $0.backgroundColor = .white
    }
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.view.addSubview(self.collectionView)
        self.inputWrapper.addSubview(self.inputField)
        self.inputWrapper.addSubview(self.sendButton)
        self.view.addSubview(self.inputWrapper)
        
        self.collectionView.refreshControl = self.refreshControl
        
        self.prepareKeyboardUp()
        
        let number = self.issue.number
        self.title = "#\(number)"
    }
    
    override func setupConstraints() {
        self.collectionView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview()
            }
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        self.inputField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.right.equalToSuperview().multipliedBy(0.8)
        }
        
        self.sendButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.left.equalTo(self.inputField.snp.right).offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        self.inputWrapper.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    func bind(reactor: Reactor) {

        self.collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
        
        self.rx.viewDidLoad
            .flatMap({ [weak self] _ -> Observable<(String, String, Int, Model.Issue)> in
                guard let owner = self?.owner, let repo = self?.repo, let number = self?.issue.number else { return .empty() }
                    guard let issue = self?.issue else { return .empty() }
                    return Observable.just((owner, repo, number, issue))
            })
            .map { (owner, repo, number, issue) -> Reactor.Action in
            return Reactor.Action.refresh(owner: owner, repo: repo, number: number, issue: issue)
        }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.collectionView.rx.isReachedBottom
            .flatMap({ [weak self] _ -> Observable<(String, String, Int, Model.Issue)> in
                guard let owner = self?.owner, let repo = self?.repo, let number = self?.issue.number else { return .empty() }
                guard let issue = self?.issue else { return .empty() }
                return Observable.just((owner, repo, number, issue))
            })
            .map { (owner, repo, number, issue) -> Reactor.Action in
            return Reactor.Action.loadMore(owner: owner, repo: repo, number: number)
        }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .flatMap({ [weak self] _ -> Observable<(String, String, Int, Model.Issue)> in
                guard let owner = self?.owner, let repo = self?.repo, let number = self?.issue.number else { return .empty() }
                guard let issue = self?.issue else { return .empty() }
                return Observable.just((owner, repo, number, issue))
            })
            .map { (owner, repo, number, issue) -> Reactor.Action in
                return Reactor.Action.refresh(owner: owner, repo: repo, number: number, issue: issue)
        }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.inputField.rx.text.flatMap { (comment) -> Observable<String> in
            guard let comment = comment else { return .empty() }
            return Observable.just(comment)
            }.map { (comment) -> Reactor.Action in
                return Reactor.Action.updateComment(comment)
        }.bind(to: reactor.action).disposed(by: self.disposeBag)
        
        self.collectionView.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] (indexPath) in
            let commentReactor = reactor.currentState.sections[indexPath.section].items[indexPath.item]
            let comment = commentReactor.currentState
            let githubService = reactor.githubService
            let reactor = MarkDownViewReactor(githubService: githubService)
            guard let owner = self?.owner, let repo = self?.repo else { return }
            guard let parentIndexPath = self?.indexPath else { return }
            let markDownView = MarkDownViewController(reactor: reactor, comment: comment, owner: owner, repo: repo, indexPath: indexPath, parentIndexPath: parentIndexPath)
            self?.navigationController?.pushViewController(markDownView, animated: true)
        }).disposed(by: self.disposeBag)
        
        self.sendButton.rx.tap
            .flatMap({ [weak self] _ -> Observable<(String, String, Int, String)> in
                guard let owner = self?.owner, let repo = self?.repo, let number = self?.issue.number else { return .empty() }
                let comment = reactor.currentState.comment
                return Observable.just((owner, repo, number, comment))
            })
            .map({ (owner, repo, number, comment) -> Reactor.Action in
                return Reactor.Action.postComment(owner: owner, repo: repo, number: number, comment: comment)
            })
            .bind(to: reactor.action).disposed(by: self.disposeBag)
        
        
        reactor.state.map { $0.sections }
            .bind(to: self.collectionView.rx.items(dataSource: self.createDataSource()))
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isRefreshing }
            .bind(to: self.refreshControl.rx.isRefreshing)
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.comment }
            .distinctUntilChanged()
            .bind(to: self.inputField.rx.text)
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.issue }
            .filter { (issue: Model.Issue?) -> Bool in
                guard let _ = issue else { return false }
                return true
            }.subscribe(onNext: { [weak self] (issue) in
                guard let issue = issue else { return }
                self?.issue = issue
            })
            .disposed(by: self.disposeBag)
        
        
    }
    
    func createDataSource() -> CommentDataSourceType {
        return CommentDataSourceType(configureCell: { (dataSource, collectionView, indexPath, reactor) -> UICollectionViewCell in
            let cell = collectionView.dequeue(Reusable.commentCell, for: indexPath)
            cell.reactor = reactor
            return cell
        }, configureSupplementaryView: { [weak self] (dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
            switch kind {
            case UICollectionElementKindSectionHeader:
                let headerView = collectionView.dequeue(Reusable.headerCell, kind: kind, for: indexPath)
                guard let issue = self?.issue else { return UICollectionReusableView() }
                guard let owner = self?.owner, let repo = self?.repo else { return headerView }
                guard let service = self?.reactor?.githubService else { return headerView }
                headerView.reactor = CommentHeaderCellReactor(issue: issue, githubService: service, owner: owner, repo: repo)
                return headerView
            case UICollectionElementKindSectionFooter:
                let footerView = collectionView.dequeue(Reusable.loadMoreCell, kind: kind, for: indexPath)
                guard let sectionItems = self?.reactor?.currentState.sections[indexPath.section].items else { return UICollectionReusableView() }
                if sectionItems.count < 30 {
                    return footerView
                }
                guard let isLastPage = self?.reactor?.currentState.reachedLastPage else { return UICollectionReusableView() }
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

    
    fileprivate func prepareKeyboardUp() {
        view.registerAutomaticKeyboardConstraints()

        self.inputWrapper.snp.prepareConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            RxKeyboard.instance.visibleHeight.drive(onNext: { (keyboardVisibleHeight) in
                make.bottom.equalToSuperview().offset(-keyboardVisibleHeight).keyboard(true, in: self.view)
            }).disposed(by: self.disposeBag)
        }
        
        self.collectionView.snp.prepareConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            RxKeyboard.instance.visibleHeight.drive(onNext: { (keyboardVisibleHeight) in
                make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(-keyboardVisibleHeight).keyboard(true, in: self.view)
                make.left.equalToSuperview().keyboard(true, in: self.view)
                make.right.equalToSuperview().keyboard(true, in: self.view)
                make.bottom.equalToSuperview().offset(-keyboardVisibleHeight).keyboard(true, in: self.view)
            }).disposed(by: self.disposeBag)
        }
    }

}

extension CommentsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let issue = self.issue else { return CGSize(width: 0, height: 0) }
        guard let owner = self.owner, let repo = self.repo else { return CGSize(width: 0, height: 0) }
        let service = GithubService()
        let reactor = CommentHeaderCellReactor(issue: issue, githubService: service, owner: owner, repo: repo)
        let titleHeight = CommentHeaderCell.heightForTitleLabel(fits: collectionView.frame.size.width, reactor: reactor)
        let descHeight = CommentHeaderCell.heightForDescLabel(fits: collectionView.frame.size.width, reactor: reactor)
        let bodyHeight = CommentHeaderCell.heightForBodyLabel(fits: collectionView.frame.size.width, reactor: reactor)
        return CGSize(width: collectionView.frame.width, height: titleHeight + descHeight + 60 + 44 + 32 + bodyHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let descHeight = 32.f
        guard let reactor = self.reactor?.currentState.sections[indexPath.section].items[indexPath.item] else { return CGSize(width: 0, height: 0) }
        let bodyHeight = CommentsCell.heightForBodyLabel(fits: collectionView.frame.width, reactor: reactor)
        
        return CGSize(width: collectionView.frame.width, height: descHeight + bodyHeight + 30)
    }
}






