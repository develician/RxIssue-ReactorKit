//
//  AppDelegate.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import OAuthSwift
import RxSwift
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var disposeBag: DisposeBag = DisposeBag()
    var provider: ServiceProvider = ServiceProvider()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow()
        let githubService = GithubService()
        let repoViewReactor = RepoViewReactor(provider: self.provider, githubService: githubService)
        let repoViewController = RepoViewController(reactor: repoViewReactor)
        let repoViewNavi = UINavigationController(rootViewController: repoViewController)
        window?.rootViewController = repoViewNavi
        window?.makeKeyAndVisible()
        
        self.checkToken()
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == "oauth-callback" {
            OAuthSwift.handle(url: url)
        }
        return true
    }
    
    func checkToken() {
        let tokenSubject: BehaviorSubject<String?> = BehaviorSubject(value:  self.provider.userDefaultsService.value(forKey: .token))
        tokenSubject.filter { (token) -> Bool in
            return token == nil
            }.subscribe(onNext: { [weak self] _ in
                let githubService = GithubService()
                guard let `self` = self else { return }
                let loginReactor = LoginViewReactor(provider: self.provider, githubService: githubService)
                let loginViewController = LoginViewController(reactor: loginReactor)
                self.window?.rootViewController?.present(loginViewController, animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
    }


}

