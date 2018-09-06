//
//  UserDefaultsService.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UserDefaultsKey {
    static var token: Key<String> { return "token" }
    static var refreshToken: Key<String> { return "refreshToken" }
    static var history: Key<[[String: String]]> { return "history" }
    static var lastRepo: Key<[String: String]> { return "lastRepo" }
    static var userInfo: Key<[String: Any]> { return "userInfo" }

}

protocol UserDefaultsServiceType {
    func value<T>(forKey key: UserDefaultsKey<T>) -> T?
    func set<T>(value: T?, forKey key: UserDefaultsKey<T>)
}

final class UserDefaultsService: BaseService, UserDefaultsServiceType {
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    func value<T>(forKey key: UserDefaultsKey<T>) -> T? {
        return self.defaults.value(forKey: key.key) as? T
    }
    
    func set<T>(value: T?, forKey key: UserDefaultsKey<T>) {
        self.defaults.set(value, forKey: key.key)
        self.defaults.synchronize()
    }
}








