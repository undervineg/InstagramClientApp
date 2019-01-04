//
//  LoginRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol LoginRoute {
    var loginTransition: Transition { get }
    
    func openLoginPage(with transition: Transition?)
}

extension LoginRoute where Self: Routable {
    var loginTransition: Transition {
        return PushTransition()
    }
    
    func openLoginPage(with transition: Transition? = nil) {
        let transition = transition ?? self.loginTransition
        let loginVC = LoginViewController()
        self.open(loginVC, with: transition)
    }
}
