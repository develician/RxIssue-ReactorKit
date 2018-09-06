//
//  LoginViewReactor.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

class LoginViewReactor: Reactor {
    
    init(provider: ServiceProviderType, githubService: GithubServiceType) {
        self.githubService = githubService
        self.provider = provider
    }
    
    enum Action {
        case login
    }
    
    struct State {
        var token: String? = nil
        var refreshToken: String? = nil
    }
    
    enum Mutation {
        case setToken(String, String)
    }

    var initialState: State = State()
    var provider: ServiceProviderType = ServiceProvider()
    var githubService: GithubServiceType

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .login:
            return self.githubService.getToken().flatMap({ (token, refreshToken) -> Observable<Mutation> in
                return Observable.just(Mutation.setToken(token, refreshToken))
            })
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setToken(token, refreshToken):
            self.provider.userDefaultsService.set(value: token, forKey: .token)
            self.provider.userDefaultsService.set(value: refreshToken, forKey: .refreshToken)
            state.token = token
            state.refreshToken = refreshToken
            return state
        }
    }

    
}
