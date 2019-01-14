//
//  SplashRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class SplashRouter: BasicRouter, SplashRouter.Routes {
    typealias Routes = AuthRoute & MainRoute
    
    var openMainCallback: ((UIViewController) -> Void)? = nil
    var openLoginCallback: ((UIViewController) -> Void)? = nil
    
    func openMainPage() {
        guard let callback = openMainCallback else { return }
        openMainPageAsWindowRoot(with: callback)
    }
    
    func openAuthPage(_ root: AuthModule.RootType) {
        guard let callback = openLoginCallback else { return }
        openMainPage()
        openAuthPageAsWindowRoot(.login, with: callback)
    }
}
