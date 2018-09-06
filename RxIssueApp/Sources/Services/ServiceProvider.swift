//
//  ServiceProvider.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//

protocol ServiceProviderType: class {
    var userDefaultsService: UserDefaultsServiceType { get }
    var appService: AppServiceType { get }
    var repoService: RepoServiceType { get }
}

final class ServiceProvider: ServiceProviderType {
    lazy var userDefaultsService: UserDefaultsServiceType = UserDefaultsService(provider: self)
    lazy var appService: AppServiceType = AppService(provider: self)
    lazy var repoService: RepoServiceType = RepoService(provider: self)
}
