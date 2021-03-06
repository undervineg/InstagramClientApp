//
//  SharePhotoRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class SharePhotoRouter: BasicRouter, SharePhotoRouter.Routes {
    typealias Routes = MainRoute
    
    var mainTransition: Transition = ModalTransition()
    
    func openMainPage() {
        openMainPage(with: mainTransition)
    }
    
    func openMainPage(with transition: Transition) {
        openTransition = transition
        openTransition?.viewController = viewController?.presentingViewController
        self.close()
    }
    
    func openMainPageAsRoot(_ callback: (UIViewController) -> Void) {
        //
    }
}
