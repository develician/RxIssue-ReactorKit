//
//  IssueCellReactor.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 6..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import ReactorKit

class IssueCellReactor: Reactor {
    
    typealias Action = NoAction


    
    let initialState: Model.Issue
    
    init(issue: Model.Issue) {
        self.initialState = issue
    }

}
