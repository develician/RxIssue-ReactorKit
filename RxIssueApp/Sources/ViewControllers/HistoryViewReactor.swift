//
//  HistoryViewReactor.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxDataSources
import RxSwift
import RxCocoa

typealias HistorySectionModel = SectionModel<Int, Repo>
typealias HistoryDataSourceType = RxTableViewSectionedReloadDataSource<HistorySectionModel>

class HistoryViewReactor: Reactor {
    
    init(provider: ServiceProviderType) {
       self.provider = provider
    }
    
    enum Action {
        case setHistories
        case setDismiss
        case setSelected(Repo)
    }
    
    struct State {
        var sections: [HistorySectionModel] = []
        var isDismissed: Bool = false
        var selectedRepo: Repo? = nil
    }
    
    enum Mutation {
        case setSections([Repo])
        case dismiss
        case setSelected(Repo)
    }
    
    var initialState: State = State()
    var provider: ServiceProviderType

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setHistories:
            guard let historiesDict = self.provider.userDefaultsService.value(forKey: .history) else { return Observable.empty() }
            let histories = Repos(dictArray: historiesDict)
            return Observable.just(Mutation.setSections(histories.repos))
        case .setDismiss:
            return Observable.just(Mutation.dismiss)
        case let .setSelected(repo):
            return Observable.just(Mutation.setSelected(repo))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setSections(repos):
            state.sections = [HistorySectionModel(model: 0, items: repos)]
            return state
        case .dismiss:
            state.isDismissed = true
            return state
        case let .setSelected(repo):
            state.isDismissed = true
            state.selectedRepo = repo
            return state
        }
    }

    
    
}
