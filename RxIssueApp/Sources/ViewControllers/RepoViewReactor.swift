//
//  RepoViewReactor.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

class RepoViewReactor: Reactor {
    
    init(provider: ServiceProviderType, githubService: GithubServiceType) {
        self.provider = provider
        self.githubService = githubService
    }
    
    enum Action {
        case logout
        case updateOwner(String)
        case updateRepo(String)
        case getUserInfo
    }
    
    struct State {
        var showLoginView: Bool = false
        var owner: String = ""
        var repo: String = ""
    }

    enum Mutation {
        case logout
        case updateOwner(String)
        case updateRepo(String)
        case showLoginView(Bool)
        case getUserInfo(Model.User)
    }
    
    var initialState: State = State()

    var provider: ServiceProviderType
    
    var githubService: GithubServiceType
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .logout:
            return Observable.concat([
                    Observable.just(Mutation.showLoginView(true)),
                    Observable.just(Mutation.logout),
                    Observable.just(Mutation.showLoginView(false))
                ])
        case let .updateOwner(owner):
            return Observable.just(Mutation.updateOwner(owner))
        case let .updateRepo(repo):
            return Observable.just(Mutation.updateRepo(repo))
        case .getUserInfo:
            return self.githubService.getUserInfo().flatMap({ (user) -> Observable<Mutation> in
                return Observable.just(Mutation.getUserInfo(user))
            })
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .logout:
            self.provider.userDefaultsService.set(value: nil, forKey: .token)
            return state
        case let .updateOwner(owner):
            state.owner = owner
            return state
        case let .updateRepo(repo):
            state.repo = repo
            return state
        case let .showLoginView(shouldShow):
            state.showLoginView = shouldShow
            return state
        case let .getUserInfo(user):
            guard let userDict = try? user.asDictionary() else { return state }
            self.provider.userDefaultsService.set(value: userDict, forKey: .userInfo)
            return state
        }
    }

    
}
