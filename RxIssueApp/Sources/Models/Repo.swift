//
//  Repo.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation

struct Repo {
    var repo: String
    var owner: String
}

extension Repo: Equatable, Hashable {
    
    init?(dict: [String: String]) {
        guard let repoString = dict["repo"] else { return nil }
        guard let ownerString = dict["owner"] else { return nil }
        repo = repoString
        owner = ownerString
    }
    
    static func ==(lhs: Repo, rhs: Repo) -> Bool {
        return lhs.repo == rhs.repo && lhs.owner == rhs.owner
    }
    
    var hashValue: Int {
        return repo.hashValue ^ owner.hashValue
    }
    
    var dict: [String: String] {
        return ["repo": repo, "owner": owner]
    }
}

struct Repos {
    var repos: [Repo]
}

extension Repos {
    init(dictArray: [[String: String]]) {
        repos = dictArray.flatMap({ (dictArray) in
            return Repo(dict: dictArray)
        })
    }
    
    func add(repo: Repo) -> Repos {
        let newRepos: [Repo] = Set<Repo>(repos + [repo]).map { (repo) -> Repo in
            return repo
        }
        return Repos(repos: newRepos)
    }
    
    var dictArray: [[String: String]] {
        return self.repos.map({ (repo) -> [String: String] in
            return repo.dict
        })
    }
}
