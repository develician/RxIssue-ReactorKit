//
//  ViewController.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import Then
import SnapKit

class LoginViewController: BaseViewController, View {
    
    let provider: ServiceProviderType = ServiceProvider()
    
    init(reactor: Reactor) {
        super.init()
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    typealias Reactor = LoginViewReactor
    
    let loginButton = UIButton(type: .system).then {
        $0.setTitle("Login", for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        self.view.addSubview(self.loginButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.loginButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func bind(reactor: Reactor) {
        self.loginButton.rx.tap.map { Reactor.Action.login }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.token }
            .filter({ (token) -> Bool in
                if let _ = token {
                    return true
                } else {
                    return false
                }
            })
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
    }

}















