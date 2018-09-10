//
//  GithubAPI.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import OAuthSwift
import RxSwift
import RxAlamofire
import RxCocoa

enum GithubEvent {
    case postComment(Model.Comment)
    case toggleIssue(Model.Issue)
    case postIssue(Model.Issue)
    case deleteComment(childIndexPath: IndexPath, parentIndexPath: IndexPath)
}

protocol GithubServiceType {
    var githubEvent: PublishSubject<GithubEvent> { get }
    var githubOAuth: OAuth2Swift { get }
    var decoder: JSONDecoder { get }
    func getToken() -> Observable<(String, String)>
    func repoIssues(pageID: Int, owner: String, repo: String) -> Observable<[Model.Issue]>
    func issueComment(pageID: Int, owner: String, repo: String, number: Int) -> Observable<[Model.Comment]>
    func toggleIssueState(owner: String, repo: String, number: Int, issue: Model.Issue) -> Observable<Model.Issue>
    func postComment(owner: String, repo: String, number: Int, comment: String) -> Observable<Model.Comment>
    func postIssue(owner: String, repo: String, title: String, body: String) -> Observable<Model.Issue>
    func getUserInfo() -> Observable<Model.User>
    func deleteComment(owner: String, repo: String, commentId: Int, indexPath: IndexPath, parentIndexPath: IndexPath) -> Observable<[String: Bool]>
    func editComment(owner: String, repo: String, commentId: Int, body: String) -> Observable<Model.Comment>
}

final class GithubService: GithubServiceType {
    
    var githubEvent: PublishSubject<GithubEvent> = PublishSubject()
    
    let githubOAuth: OAuth2Swift = OAuth2Swift(
        consumerKey: "425bdcda7d5df5fddee0",
        consumerSecret: "8b150f10b2d2fc98fd6735f7014aa87b21d18561",
        authorizeUrl: "https://github.com/login/oauth/authorize",
        accessTokenUrl: "https://github.com/login/oauth/access_token",
        responseType: "code"
    )
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
    
    func getToken() -> Observable<(String, String)> {
        guard let authURL = URL(string: "RxIssueApp://oauth-callback/github") else {
            return Observable.empty()
        }
        
        return Observable<(String, String)>.create({ (observer) -> Disposable in
            self.githubOAuth.authorize(withCallbackURL: authURL, scope: "user,repo", state: "state", success: { (credential, response, params) in
                let oauthToken = credential.oauthToken
                let refreshToken = credential.oauthRefreshToken
                observer.onNext((oauthToken, refreshToken))
            }, failure: { (error) in
                observer.onError(error)
            })
            return Disposables.create {
                
            }
        })
    }
    
    func repoIssues(pageID: Int, owner: String, repo: String) -> Observable<[Model.Issue]> {
        let parameters: [String: Any] = ["page": pageID, "state": "all"]
        return GithubAPI.repoIssues(owner: owner, repo: repo).buildRequest(parameters: parameters).map({ (data: Data) -> [Model.Issue] in
            guard let issues = (try? self.decoder.decode([Model.Issue].self, from: data)) else {
                return [] }
            return issues
        })
        
    }
    
    func issueComment(pageID: Int, owner: String, repo: String, number: Int) -> Observable<[Model.Comment]> {
        let parameters: [String: Any] = ["page": pageID]
        return GithubAPI.issueComment(owner: owner, repo: repo, number: number).buildRequest(parameters: parameters).map({ (data: Data) -> [Model.Comment] in
            guard let comments = try? self.decoder.decode([Model.Comment].self, from: data) else { return [] }
            return comments
        })
    }
    
    func toggleIssueState(owner: String, repo: String, number: Int, issue: Model.Issue) -> Observable<Model.Issue> {
        guard let issueDict = try? issue.asDictionary() else { return Observable.empty() }
        return GithubAPI.editIssue(owner: owner, repo: repo, number: number).buildRequest(parameters: issueDict).flatMap({ (data: Data) -> Observable<Model.Issue> in
            guard let issue = try? self.decoder.decode(Model.Issue.self, from: data) else { return Observable.error(RxError.noElements) }
            return Observable.just(issue)
        }).do(onNext: { (issue) in
            self.githubEvent.onNext(.toggleIssue(issue))
        })
    }
    
    func postComment(owner: String, repo: String, number: Int, comment: String) -> Observable<Model.Comment> {
        let parameters: [String: Any] = ["body": comment]
        return GithubAPI.postComment(owner: owner, repo: repo, number: number).buildRequest(parameters: parameters).flatMap({ (data: Data) -> Observable<Model.Comment> in
            guard let comment = try? self.decoder.decode(Model.Comment.self, from: data) else {
                return Observable.error(RxError.noElements)
            }
            return Observable.just(comment)
        }).do(onNext: { (comment: Model.Comment) in
            self.githubEvent.onNext(.postComment(comment))
        })
    }
    
    func postIssue(owner: String, repo: String, title: String, body: String) -> Observable<Model.Issue> {
        let parameters: [String: Any] = ["title": title, "body": body]
        return GithubAPI.postIssue(owner: owner, repo: repo).buildRequest(parameters: parameters).flatMap({ (data) -> Observable<Model.Issue> in
            guard let issue = try? self.decoder.decode(Model.Issue.self, from: data) else {
                return Observable.error(RxError.noElements)
            }
            return Observable.just(issue)
        }).do(onNext: { (issue) in
            self.githubEvent.onNext(.postIssue(issue))
        })
    }
    
    func getUserInfo() -> Observable<Model.User> {
        let parameters: [String: Any] = [:]
        return GithubAPI.getUserInfo.buildRequest(parameters: parameters).flatMap({ (data) -> Observable<Model.User> in
            guard let user = try? self.decoder.decode(Model.User.self, from: data) else {
                return Observable.error(RxError.noElements)
            }
            return Observable.just(user)
        })
    }
    
    func deleteComment(owner: String, repo: String, commentId: Int, indexPath: IndexPath, parentIndexPath: IndexPath) -> Observable<[String: Bool]> {
        let parameters: [String: Any] = [:]
        return GithubAPI.deleteComment(owner: owner, repo: repo, commentId: commentId)
            .buildRequest(parameters: parameters)
            .flatMap({ (data) -> Observable<[String: Bool]> in
                return Observable.just(["success": true])
            }).do(onNext: { _ in
                self.githubEvent.onNext(.deleteComment(childIndexPath: indexPath, parentIndexPath: parentIndexPath))
            })
    }
    
    func editComment(owner: String, repo: String, commentId: Int, body: String) -> Observable<Model.Comment> {
        let parameters: [String: Any] = ["body": body]
        return GithubAPI.editComment(owner: owner, repo: repo, commentId: commentId)
            .buildRequest(parameters: parameters)
            .flatMap({ (data) -> Observable<Model.Comment> in
                guard let comment = try? self.decoder.decode(Model.Comment.self, from: data) else { return Observable.error(RxError.unknown) }
                return Observable.just(comment)
            })
    }
    
}

















