//
//  PostIssueViewReactor.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

class PostIssueViewReactor: Reactor {
    
    init(githubService: GithubServiceType) {
        self.githubService = githubService
    }
    
    enum Action {
        case setDismiss
        case updateTitle(String)
        case updateContent(String)
        case postIssue(owner: String, repo: String, title: String, body: String)
    }
    
    struct State {
        var isDismissed: Bool = false
        var title: String = ""
        var content: String = ""
        var newIssuePosted: Bool = false
        var newIssue: Model.Issue? = nil
        var isLoading: Bool = false
    }

    enum Mutation {
        case setDismiss
        case updateTitle(String)
        case updateContent(String)
        case newIssuePost(Model.Issue)
        case setLoading(Bool)
    }

    var initialState: State = State()
    
    var githubService: GithubServiceType

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setDismiss:
            return Observable.just(Mutation.setDismiss)
        case let .updateTitle(title):
            return Observable.just(Mutation.updateTitle(title))
        case let .updateContent(content):
            return Observable.just(Mutation.updateContent(content))
        case let .postIssue(owner, repo, title, body):
            let postIssueObservable = self.githubService.postIssue(owner: owner, repo: repo, title: title, body: body)
                .flatMap({ (issue: Model.Issue) -> Observable<Mutation> in
                    return Observable.just(Mutation.newIssuePost(issue))
                })
            return Observable.concat([
                    Observable.just(Mutation.setLoading(true)),
                    postIssueObservable,
                    Observable.just(Mutation.setLoading(false))
                ])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setDismiss:
            state.isDismissed = true
            return state
        case let .updateTitle(title):
            state.title = title
            return state
        case let .updateContent(content):
            state.content = content
            return state
        case let .newIssuePost(issue):
            state.newIssuePosted = true
            state.newIssue = issue
            return state
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            return state
        }
    }

}
