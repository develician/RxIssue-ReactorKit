//
//  Model.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxDataSources

struct Model {}

extension Model {
    struct User: Codable {
        var id: Int
        var login: String
        var avatarURL: URL?
        
        enum CodingKeys: String, CodingKey {
            case id
            case login
            case avatarURL = "avatar_url"
        }
    }
    
}

extension Model {
    struct Issue: Codable {
        let id: Int
        let number: Int
        let title: String
        let user: Model.User
        let state: State
        let comments: Int
        let body: String
        let createdAt: Date?
        
        enum CodingKeys: String, CodingKey {
            case id
            case user
            case body
            case number
            case title
            case comments
            case state
            case createdAt = "created_at"
        }
    }
}

extension Model {
    struct Comment: Codable, Equatable, IdentifiableType {
        let id: Int
        let user: Model.User
        let body: String
        let createdAt: Date?
        
        enum CodingKeys: String, CodingKey {
            case id
            case user
            case body
            case createdAt = "created_at"
        }
        
        var identity: Int {
            return id
        }
        
        
        static func ==(lhs: Model.Comment, rhs: Model.Comment) -> Bool {
            return lhs.id == rhs.id
        }
    }
}

extension Model.Issue {
    enum State: String, Codable {
        case open
        case closed
    }
    
    func update(state: Model.Issue.State) -> Model.Issue {
        return Model.Issue(id: self.id, number: self.number, title: self.title, user: self.user, state: state, comments: self.comments, body: self.body, createdAt: self.createdAt)
    }
    func update(commentsCount: Int) -> Model.Issue {
        return Model.Issue(id: self.id, number: self.number, title: self.title, user: self.user, state: self.state, comments: commentsCount, body: self.body, createdAt: self.createdAt)
    }
}

extension Model.Issue: Equatable, IdentifiableType {
    
    var identity: Int {
        return id
    }
    
    static func ==(lhs: Model.Issue, rhs: Model.Issue) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Model.Issue.State {
    var color: UIColor {
        switch self {
        case .open:
            return UIColor(red: 131/255, green: 189/255, blue: 71/255, alpha: 1)
        case .closed:
            return UIColor(red: 176/255, green: 65/255, blue: 32/255, alpha: 1)
        }
    }
}

