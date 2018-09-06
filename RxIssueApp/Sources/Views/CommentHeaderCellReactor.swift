//
//  CommentHeaderReactor.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

class CommentHeaderCellReactor: Reactor {
    
    
//    typealias Action = NoAction
    
    enum Action {
        case toggleState(Model.Issue)
    }
    
    enum Mutation {
        case toggleState(Model.Issue)
    }
    
    func mutate(action: CommentHeaderCellReactor.Action) -> Observable<CommentHeaderCellReactor.Mutation> {
        switch action {
        case let .toggleState(issue):
            if issue.state == .closed {
                let updatedIssue = issue.update(state: Model.Issue.State.open)
                return self.githubService.toggleIssueState(owner: self.owner, repo: self.repo, number: issue.number, issue: updatedIssue)
                    .flatMap({ (issue: Model.Issue) -> Observable<Mutation> in
                        return Observable.just(Mutation.toggleState(issue))
                    })
                
            } else {
                let updatedIssue = issue.update(state: Model.Issue.State.closed)
                return self.githubService.toggleIssueState(owner: self.owner, repo: self.repo, number: issue.number, issue: updatedIssue)
                    .flatMap({ (issue: Model.Issue) -> Observable<Mutation> in
                        return Observable.just(Mutation.toggleState(issue))
                    })
            }
            
        }
    }
    
    func reduce(state: Model.Issue, mutation: CommentHeaderCellReactor.Mutation) -> Model.Issue {
        var state = state
        switch mutation {
        case let .toggleState(updatedIssue):
            state = updatedIssue
            return state
        }
    }
    
    var initialState: Model.Issue
    
    var githubService: GithubServiceType
    var owner: String
    var repo: String
    
    
    init(issue: Model.Issue, githubService: GithubServiceType, owner: String, repo: String) {
        self.initialState = issue
        self.githubService = githubService
        self.owner = owner
        self.repo = repo
    }

    
}
