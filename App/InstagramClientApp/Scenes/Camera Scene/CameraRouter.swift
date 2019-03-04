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
    
    var homeTransition: Transition = ModalTransition()
    
    func openHomeFeedPage() {
        openHomeFeedPage(with: homeTransition)
    }
    
    func openHomeFeedPage(with transition: Transition) {
        openTransition = transition
        openTransition?.viewController = viewController?.presentingViewController
        self.close()
    }
}
