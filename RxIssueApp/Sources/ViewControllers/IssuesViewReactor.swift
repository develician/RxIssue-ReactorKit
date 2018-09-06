//
//  IssuesViewReactor.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift
import RxDataSources

typealias IssueSectionModel = SectionModel<Int, IssueCellReactor>
typealias IssueDataSourceType = RxCollectionViewSectionedReloadDataSource<IssueSectionModel>

class IssuesViewReactor: Reactor {
    
    init(githubService: GithubServiceType) {
        self.githubService = githubService
    }
    
    enum Action {
        case refresh(owner: String, repo: String)
        case loadMore(owner: String, repo: String)
        case updateIssue(updatedIssue: Model.Issue, indexPath: IndexPath)
        case noAction
    }
    
    struct State {
        var sections: [IssueSectionModel] = []
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var nextPage: Int = 1
        var reachedLastPage: Bool = false
    }
    
    enum Mutation {
        case setSections([IssueSectionModel])
        case setLoading(Bool)
        case setRefreshing(Bool)
        case addIssues([IssueCellReactor])
        case updateIssue(Model.Issue, IndexPath)
    }
    
    var initialState: State = State()
    var githubService: GithubServiceType

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .refresh(owner, repo):
            let repoIssuesObservable = self.githubService.repoIssues(pageID: 1, owner: owner, repo: repo)
                .flatMap({ (issues) -> Observable<Mutation> in
                    let sectionItems = issues.map(IssueCellReactor.init)
                    let section = IssueSectionModel(model: 0, items: sectionItems)
                    return Observable.just(Mutation.setSections([section]))
                })
            return Observable.concat([
                    Observable.just(Mutation.setRefreshing(true)),
                    repoIssuesObservable,
                    Observable.just(Mutation.setRefreshing(false))
                ])
        case let .loadMore(owner, repo):
            guard !self.currentState.isLoading else { return Observable.empty() }
            guard !self.currentState.isRefreshing else { return Observable.empty() }
            guard !self.currentState.reachedLastPage else { return Observable.empty() }
            let nextPage = self.currentState.nextPage
            let loadMoreObservable = self.githubService.repoIssues(pageID: nextPage, owner: owner, repo: repo)
                .flatMap({ (issues) -> Observable<Mutation> in
                    let sectionItems = issues.map(IssueCellReactor.init)
                    return Observable.just(Mutation.addIssues(sectionItems))
                })
            return Observable.concat([
                    Observable.just(Mutation.setLoading(true)),
                    loadMoreObservable,
                    Observable.just(Mutation.setLoading(false))
                ])
        case let .updateIssue(updatedIssue, indexPath):
            return Observable.just(Mutation.updateIssue(updatedIssue, indexPath))
        case .noAction:
            return .empty()
        }
    }

    

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setSections(sections):
            state.sections = sections
            state.nextPage = 2
            state.isRefreshing = false
            state.reachedLastPage = false
            return state
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return state
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
            return state
        case let .addIssues(sectionItems):
            let updatedSectionItems = state.sections[0].items + sectionItems
            state.sections[0].items = updatedSectionItems
            state.nextPage += 1
            if sectionItems.count < 30 {
                state.reachedLastPage = true
            }
            return state
        case let .updateIssue(updatedIssue, indexPath):
            let reactor = IssueCellReactor(issue: updatedIssue)
            state.sections[indexPath.section].items[indexPath.item] = reactor
            return state
        }
    }
    
    
}
