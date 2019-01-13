//
//  MainRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol MainRoute {
    func openMainPage()
    func openMainPageWithTransition()
    func openMainPageAsRoot(with openLoginCallback: @escaping (UIViewController) -> Void)
}

extension MainRoute where Self: Closable {
    func openMainPage() {
        openMainPageWithTransition()
    }
    
    func openMainPageWithTransition() {
        self.close(to: nil)
    }
    
    func openMainPageAsRoot(with openLoginCallback: @escaping (UIViewController) -> Void) {
        let router = MainRouter()
        let mainModule = MainModule(router: router)
        router.openLoginCallback = openLoginCallback
        openLoginCallback(mainModule.viewController)
    }
}
