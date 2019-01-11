//
//  SplashRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class SplashRouter: BasicRouter, SplashRouter.Routes {
    typealias Routes = MainRouter.Routes & RegisterRouter.Routes
    
    var openRegisterCallback: ((UIViewController) -> Void)? = nil
    var openMainCallback: ((UIViewController) -> Void)? = nil
    
    func openMainPage() {
        guard let callback = openMainCallback else { return }
        openMainPageAsRoot(with: callback)
    }
    
    func openRegisterPage() {
        guard let callback = openRegisterCallback else { return }
        openRegisterPageAsRoot(with: callback)
    }
}
