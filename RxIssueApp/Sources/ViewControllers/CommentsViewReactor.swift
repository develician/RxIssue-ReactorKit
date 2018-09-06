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
        case refresh(owner: String, repo: String, number: Int)
        case loadMore(owner: String, repo: String, number: Int)
        case postComment(owner: String, repo: String, number: Int, comment: String)
        case updateComment(String)
//        case updateIssue(updatedIssue: Model.Issue, indexPath: IndexPath, owner: String, repo: String)
//        case editIssue(owner: String, repo: String, number: Int, updatedIssue: Model.Issue)
    }
    
    struct State {
        var sections: [CommentSectionModel] = []
        var nextPage: Int = 1
        var isRefreshing: Bool = false
        var isLoading: Bool = false
        var reachedLastPage: Bool = false
        var comment: String = ""
//        var toggledIssue: Model.Issue? = nil
    }

    enum Mutation {
        case setSections([CommentSectionModel])
        case setRefreshing(Bool)
        case setLoading(Bool)
        case addSectionItems([CommentSectionModel])
        case setNewComment(Model.Comment)
        case updateComment(String)
//        case updateIssue(Model.Issue, IndexPath, String, String)
//        case toggleIssue(Model.Issue)
    }

    var initialState: State = State()
    var githubService: GithubServiceType

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .refresh(owner, repo, number):
            let commentsObservable = self.githubService.issueComment(pageID: 1, owner: owner, repo: repo, number: number)
                .flatMap({ (comments: [Model.Comment]) -> Observable<Mutation> in
                    let sectionItems = comments.map(CommentsCellReactor.init)
                    let section = CommentSectionModel(model: 0, items: sectionItems)
                    return Observable.just(Mutation.setSections([section]))
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
                .flatMap({ (comment: Model.Comment) -> Observable<Mutation> in
                    return Observable.just(Mutation.setNewComment(comment))
                })
        case let .updateComment(comment):
            return Observable.just(Mutation.updateComment(comment))

//        case let .updateIssue(updatedIssue, indexPath, owner, repo):
//            return Observable.just(Mutation.updateIssue(updatedIssue, indexPath, owner, repo))
//        case let .editIssue(owner, repo, number, updatedIssue):
//            return self.githubService.toggleIssueState(owner: owner, repo: repo, number: number, issue: updatedIssue)
//                .flatMap({ (issue: Model.Issue) -> Observable<Mutation> in
//                    return Observable.just(Mutation.toggleIssue(issue))
//                })
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setSections(sections):
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
            return state
        case let .updateComment(comment):
            state.comment = comment
            return state
//        case let .updateIssue(updatedIssue, indexPath, owner, repo):
//            state.sections[indexPath.section].items[indexPath.item] = reactor
//            return state
//        case let .toggleIssue(issue):
//            state.toggledIssue = issue
//            return state
        }
    }

    
    
}
