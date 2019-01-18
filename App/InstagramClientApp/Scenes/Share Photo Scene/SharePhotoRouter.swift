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
    
    var mainTransitionType: TransitionType = .modal
    
    func openMainPage() {
        openMainPage(with: mainTransitionType)
    }
    
    func openMainPage(with transitionType: TransitionType) {
        openTransition = transitionType.object
        openTransition?.viewControllerBehind = viewControllerBehind?.presentingViewController
        self.close()
    }
    
    func openMainPageAsRoot(_ callback: (UIViewController) -> Void) {
        //
    }
}
