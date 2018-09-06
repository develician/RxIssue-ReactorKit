//
//  GithubAPI.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import RxAlamofire
import RxSwift
import Alamofire


enum GithubAPI {
    case repoIssues(owner: String, repo: String)
    case issueComment(owner: String, repo: String, number: Int)
    case editIssue(owner: String, repo: String, number: Int)
    case postComment(owner: String, repo: String, number: Int)
    case postIssue(owner: String, repo: String)
    case getUserInfo
    case deleteComment(owner: String, repo: String, commentId: Int)
    case editComment(owner: String, repo: String, commentId: Int)
}

extension GithubAPI {
    static let baseURLString: String = "https://api.github.com"
    
    
    var path: String {
        switch self {
        case let .repoIssues(owner, repo):
            return "/repos/\(owner)/\(repo)/issues"
        case let .issueComment(owner, repo, number):
            return "/repos/\(owner)/\(repo)/issues/\(number)/comments"
        case .editIssue(let onwer, let repo, let number):
            return "/repos/\(onwer)/\(repo)/issues/\(number)"
        case .postComment(let owner, let repo, let number):
            return "/repos/\(owner)/\(repo)/issues/\(number)/comments"
        case .postIssue(let owner, let repo):
            return "/repos/\(owner)/\(repo)/issues"
        case .getUserInfo:
            return "/user"
        case let .deleteComment(owner, repo, commentId), let .editComment(owner, repo, commentId):
            return "/repos/\(owner)/\(repo)/issues/comments/\(commentId)"
        }
    }
    
    
    var url: URL {
        let url = (try? GithubAPI.baseURLString.asURL())!
        return url.appendingPathComponent(path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .repoIssues, .issueComment, .getUserInfo:
            return HTTPMethod.get
        case .editIssue, .editComment:
            return .patch
        case .postComment, .postIssue:
            return .post
        case .deleteComment:
            return .delete
            
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .repoIssues, .issueComment, .getUserInfo, .deleteComment:
            return URLEncoding.default
        case .editIssue, .postComment, .postIssue, .editComment:
            return JSONEncoding.default
        }
    }
    
    static var defaultHeaders: HTTPHeaders {
        var headers: HTTPHeaders = [:]
        let provider = ServiceProvider()
        if let token = provider.userDefaultsService.value(forKey: .token), !token.isEmpty {
            headers["Authorization"] = "token \(token)"
        }
        return headers
    }
    
    static let manager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    
    func buildRequest(parameters: Parameters) -> Observable<Data> {
        let provider = ServiceProvider()
        return GithubAPI.manager.rx.request(method, url, parameters: parameters, encoding: parameterEncoding, headers: GithubAPI.defaultHeaders)
            .validate(statusCode: 200 ..< 300)
            .data()
            .observeOn(MainScheduler.instance)
            .do(onError: { (error) in
                let alert = UIAlertController(title: "error",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                provider.appService.delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
            })
    }
}
