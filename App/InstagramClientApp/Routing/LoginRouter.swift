//
//  LoginRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 13/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class LoginRouter: BasicRouter, LoginRouter.Routes {
    typealias Routes = RegisterRoute & MainRoute
    
    var openMainCallback: ((UIViewController) -> Void)? = nil
    
    func openMainPage() {
        if let callback = openMainCallback {
            openMainPageAsRoot(with: callback)
            openMainCallback = nil
        } else {
            openMainPageWithTransition()
        }
    }
}
