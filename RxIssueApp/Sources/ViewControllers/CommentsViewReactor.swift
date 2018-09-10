//
//  CommentsViewReactor.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources

typealias CommentSectionModel = SectionModel<Int, CommentsCellReactor>
typealias CommentDataSourceType = RxCollectionViewSectionedReloadDataSource<CommentSectionModel>

class CommentsViewReactor: Reactor {
    
    init(githubService: GithubServiceType) {
        self.githubService = githubService
    }
    
    enum Action {
        case refresh(owner: String, repo: String, number: Int, issue: Model.Issue)
        case loadMore(owner: String, repo: String, number: Int)
        case postComment(owner: String, repo: String, number: Int, comment: String)
        case updateComment(String)
    }
    
    struct State {
        var issue: Model.Issue? = nil
        var sections: [CommentSectionModel] = []
        var nextPage: Int = 1
        var isRefreshing: Bool = false
        var isLoading: Bool = false
        var reachedLastPage: Bool = false
        var comment: String = ""
//        var toggledIssue: Model.Issue? = nil
    }

    enum Mutation {
        case setSections([CommentSectionModel], Model.Issue)
        case setRefreshing(Bool)
        case setLoading(Bool)
        case addSectionItems([CommentSectionModel])
        case setNewComment(Model.Comment)
        case updateComment(String)
        case toggleIssue(Model.Issue)
        case deleteComment(IndexPath)
    }

    var initialState: State = State()
    var githubService: GithubServiceType

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .refresh(owner, repo, number, issue):
            let commentsObservable = self.githubService.issueComment(pageID: 1, owner: owner, repo: repo, number: number)
                .flatMap({ (comments: [Model.Comment]) -> Observable<Mutation> in
                    let sectionItems = comments.map(CommentsCellReactor.init)
                    let section = CommentSectionModel(model: 0, items: sectionItems)
                    return Observable.just(Mutation.setSections([section], issue))
                })
            return Observable.concat([
                    Observable.just(Mutation.setRefreshing(true)),
                    commentsObservable,
                    Observable.just(Mutation.setRefreshing(false))
                ])
        case let .loadMore(owner, repo, number):
            guard !self.currentState.isLoading else { return .empty() }
            guard !self.currentState.isRefreshing else { return .empty() }
            guard !self.currentState.reachedLastPage else { return .empty() }
            let nextPage = self.currentState.nextPage
            let loadMoreObservable = self.githubService.issueComment(pageID: nextPage, owner: owner, repo: repo, number: number)
                .flatMap({ (comments: [Model.Comment]) -> Observable<Mutation> in
                    let sectionItems = comments.map(CommentsCellReactor.init)
                    let section = CommentSectionModel(model: 0, items: sectionItems)
                    return Observable.just(Mutation.addSectionItems([section]))
                })
            return Observable.concat([
                    Observable.just(Mutation.setLoading(true)),
                    loadMoreObservable,
                    Observable.just(Mutation.setLoading(false))
                ])
        case let .postComment(owner, repo, number, comment):
            return self.githubService.postComment(owner: owner, repo: repo, number: number, comment: comment)
                .flatMap({ _ -> Observable<Mutation> in
                    return .empty()
                })
        case let .updateComment(comment):
            return Observable.just(Mutation.updateComment(comment))
        }
    }

    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let githubEventMutation = self.githubService.githubEvent.flatMap { [weak self] (githubEvent: GithubEvent) -> Observable<Mutation> in
            self?.mutate(githubEvent: githubEvent) ?? .empty()
        }
        
        return Observable.of(mutation, githubEventMutation).merge()
    }
    
    private func mutate(githubEvent: GithubEvent) -> Observable<Mutation> {
        let state = self.currentState
        switch githubEvent {
        case .postComment(let comment):
            return Observable.just(Mutation.setNewComment(comment))
        case .toggleIssue(let issue):
            return Observable.just(Mutation.toggleIssue(issue))
        case .deleteComment(let indexPath, _):
            return Observable.just(Mutation.deleteComment(indexPath))
        default:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setSections(sections, issue):
            state.issue = issue
            state.sections = sections
            state.nextPage = 2
            state.reachedLastPage = false
            return state
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
            return state
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return state
        case let .addSectionItems(sections):
            let sectionItems = sections[0].items
            let updatedSections = state.sections[0].items + sectionItems
            state.sections[0].items = updatedSections
            if sectionItems.count < 30 {
                state.reachedLastPage = true
            }
            state.nextPage += 1
            return state
        case let .setNewComment(comment):
            let reactor = CommentsCellReactor(comment: comment)
            state.sections[0].items.append(reactor)
            state.comment = ""
            guard let currentCount = state.issue?.comments else { return state }
            guard let newIssue = state.issue?.update(commentsCount: currentCount + 1) else { return state }
            state.issue = newIssue
            return state
        case let .updateComment(comment):
            state.comment = comment
            return state
        case .toggleIssue(let issue):
            state.issue = issue
            return state
        case .deleteComment(let indexPath):
            state.sections[indexPath.section].items.remove(at: indexPath.item)
            guard let comments = state.issue?.comments else { return state }
            guard let newIssue = state.issue?.update(commentsCount: comments - 1) else { return state }
            state.issue = newIssue
            return state
        }
    }

    
    
}
