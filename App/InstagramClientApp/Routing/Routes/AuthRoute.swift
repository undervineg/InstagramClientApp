//
//  AuthRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 14/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol AuthRoute {
    var authTransition: TransitionType { get }
    
    func openAuthPage(_ root: AuthModule.RootType)
    func openAuthPage(_ root: AuthModule.RootType, with transitionType: TransitionType)
    func openAuthPageAsRoot(_ root: AuthModule.RootType, _ callback: (UIViewController) -> Void)
}
