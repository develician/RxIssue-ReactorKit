//
//  CommentsCellReactor.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit

class CommentsCellReactor: Reactor {
    typealias Action = NoAction
    
    let initialState: Model.Comment
    
    init(comment: Model.Comment) {
        self.initialState = comment
    }

    
}
