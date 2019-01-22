//
//  CameraRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class CameraRouter: BasicRouter, CameraRouter.Routes {
    typealias Routes = HomeFeedRoute & SettingsRoute
    
    var homeTransitionType: TransitionType = .modal
    
    func openHomeFeedPage() {
        openHomeFeedPage(with: homeTransitionType)
    }
    
    func openHomeFeedPage(with transitionType: TransitionType) {
        openTransition = transitionType.object
        openTransition?.viewControllerBehind = viewControllerBehind?.presentingViewController
        self.close()
    }
}
