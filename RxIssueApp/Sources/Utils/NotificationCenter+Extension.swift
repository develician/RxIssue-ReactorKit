//
//  NotificationCenter+Extension.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let NewIssuePosted = Notification.Name("NewIssuePosted")
    static let IssueStateToggled = Notification.Name("IssueStateToggled")
    static let CommentDeleted = Notification.Name("CommentDeleted")
    static let CommentUpdated = Notification.Name("CommentUpdated")

}
