//
//  MakrDownViewReactor.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

class MarkDownViewReactor: Reactor {
    
    init(githubService: GithubServiceType) {
        self.githubService = githubService
    }
    
    enum Action {
        case updateMarkDown(String)
        case deleteComment(owner: String, repo: String, commentId: Int, indexPath: IndexPath, parentIndexPath: IndexPath)
        case updateComment(owner: String, repo: String, commentId: Int, body: String)
    }
    
    struct State {
        var markDown: String = ""
        var deleted: Bool = false
        var updated: Bool = false
        var updatedComment: Model.Comment? = nil
        var isDismissed: Bool = false
    }

    enum Mutation {
        case updateMarkDown(String)
        case deleteComment(Bool)
        case updateComment(Model.Comment)
        case dismiss
    }

    var initialState: State = State()
    var githubService: GithubServiceType

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateMarkDown(markDown):
            return Observable.just(Mutation.updateMarkDown(markDown))
        case let .deleteComment(owner, repo, commentId, indexPath, parentIndexPath):
            return self.githubService.deleteComment(owner: owner, repo: repo, commentId: commentId, indexPath: indexPath, parentIndexPath: parentIndexPath)
                .flatMap({ (isSuccess) -> Observable<Mutation> in
                    guard let isSuccess = isSuccess["success"] else { return .empty() }
                    return Observable.just(Mutation.deleteComment(isSuccess))
                })
        case let .updateComment(owner, repo, commentId, body):
            return self.githubService.editComment(owner: owner, repo: repo, commentId: commentId, body: body)
                .flatMap({ (comment) -> Observable<Mutation> in
                    return Observable.just(Mutation.updateComment(comment))
                })
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let githubEventMutation = self.githubService.githubEvent.flatMap { [weak self] (githubEvent) -> Observable<Mutation> in
            self?.mutate(githubEvent: githubEvent) ?? .empty()
        }
        
        return Observable.of(mutation, githubEventMutation).merge()
    }
    
    private func mutate(githubEvent: GithubEvent) -> Observable<Mutation> {
        let state = self.currentState
        switch githubEvent {
        case .editComment(_):
            return Observable.just(Mutation.dismiss)
        default:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .updateMarkDown(markDown):
            state.markDown = markDown
            return state
        case let .deleteComment(isSuccess):
            state.deleted = isSuccess
            return state
        case let .updateComment(comment):
            state.updatedComment = comment
            state.updated = true
            return state
        case .dismiss:
            state.isDismissed = true
            return state
        }
    }
    
    
    
}
