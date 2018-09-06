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
        case deleteComment(owner: String, repo: String, commentId: Int)
        case updateComment(owner: String, repo: String, commentId: Int, body: String)
    }
    
    struct State {
        var markDown: String = ""
        var deleted: Bool = false
        var updated: Bool = false
        var updatedComment: Model.Comment? = nil
    }

    enum Mutation {
        case updateMarkDown(String)
        case deleteComment(Bool)
        case updateComment(Model.Comment)
    }

    var initialState: State = State()
    var githubService: GithubServiceType

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateMarkDown(markDown):
            return Observable.just(Mutation.updateMarkDown(markDown))
        case let .deleteComment(owner, repo, commentId):
            return self.githubService.deleteComment(owner: owner, repo: repo, commentId: commentId)
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
        }
    }
    
    
    
}
