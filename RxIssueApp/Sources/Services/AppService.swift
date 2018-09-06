//
//  AppService.swift
//  RxIssueApp
//
//  Created by killi8n on 2018. 9. 5..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit

protocol AppServiceType {
    var delegate: AppDelegate { get }
}

final class AppService: BaseService, AppServiceType {
    var delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

}
