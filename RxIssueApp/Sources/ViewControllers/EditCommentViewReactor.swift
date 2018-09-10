//
//  EditCommentViewReactor.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 11..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

class EditCommentViewReactor: Reactor {
    
    init(githubService: GithubServiceType) {
        self.githubService = githubService
    }
    
    enum Action {
        case dismiss
        case editComment(owner: String, repo: String, commentId: Int, body: String)
        case updateComment(String)
    }
    
    struct State {
        var isDismissed: Bool = false
        var comment: String = ""
    }
    
    enum Mutation {
        case dismiss
        case updateComment(String)
    }

    var initialState: State = State()
    
    let githubService: GithubServiceType

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .dismiss:
            return Observable.just(Mutation.dismiss)
        case .editComment(let owner, let repo, let commentId, let body):
            return self.githubService.editComment(owner: owner, repo: repo, commentId: commentId, body: body).flatMap({ _ -> Observable<Mutation> in
                return Observable.just(Mutation.dismiss)
            })
        case .updateComment(let comment):
            return Observable.just(Mutation.updateComment(comment))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .dismiss:
            state.isDismissed = true
            return state
        case .updateComment(let comment):
            state.comment = comment
            return state
        }
    }

    
}
