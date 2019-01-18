//
//  LoginRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol LoginRoute {
    var loginTransitionType: TransitionType { get }
    
    func openLoginPage()
    func openLoginPage(with transitionType: TransitionType)
    func openLoginPageAsRoot(_ callback: (UIViewController) -> Void)
}
