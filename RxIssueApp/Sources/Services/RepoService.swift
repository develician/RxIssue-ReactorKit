//
//  RepoService.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit

protocol RepoServiceType {
    var history: Repos { get }
    var lastRepo: Repo? { get }
    func addHistory(owner: String, repo: String)
    func setLastRepo(owner: String, repo: String)
}

final class RepoService: BaseService, RepoServiceType {
    
    
    
    
    var history: Repos {
        get {
            let repos = self.provider.userDefaultsService.value(forKey: .history) ?? []
            return Repos(dictArray: repos)
        }
    }
    
    var lastRepo: Repo? {
        get {
            guard let repoDict = self.provider.userDefaultsService.value(forKey: .lastRepo) else { return nil }
            guard let repo = Repo(dict: repoDict) else { return nil }
            return repo
        }
    }
    
    func addHistory(owner: String, repo: String) {
        let repo = Repo(repo: repo, owner: owner)
        let repos = self.history.add(repo: repo)
        self.provider.userDefaultsService.set(value: repos.dictArray, forKey: .history)
    }
    
    func setLastRepo(owner: String, repo: String) {
        let repo = Repo(repo: repo, owner: owner)
        self.provider.userDefaultsService.set(value: repo.dict, forKey: .lastRepo)
    }
}
