//
//  UserDefaultsKey.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//


struct UserDefaultsKey<T> {
    typealias Key<T> = UserDefaultsKey<T>
    let key: String
}

extension UserDefaultsKey: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(key: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(key: value)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(key: value)
    }
}
