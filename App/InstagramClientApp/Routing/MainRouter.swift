//
//  MainRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class MainRouter: BasicRouter, MainRouter.Routes {
    typealias Routes = RegisterRoute & LoginRoute
    
    var openRegisterCallback: ((UIViewController) -> Void)? = nil
    
    func openRegisterPage() {
        if let callback = openRegisterCallback {
            openRegisterPageAsRoot(with: callback)
            openRegisterCallback = nil
        } else {
            openRegisterPageWithTransition()
        }
    }
}
