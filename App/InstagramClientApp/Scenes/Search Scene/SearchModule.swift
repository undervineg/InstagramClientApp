//
//  SearchModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class SearchModule {
    private let viewController: UserSearchViewController
    
    var withNavigation: UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
    
    init() {
        viewController = UserSearchViewController()
    }
}
