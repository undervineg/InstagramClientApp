//
//  PhotoSelectorModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class PhotoSelectorModule {
    let router: MainRouter
    let viewController: PhotoSelectorViewController
    
    var withNavigation: UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
    
    init(router: MainRouter) {
        self.router = router
        viewController = PhotoSelectorViewController(router: router)
    }
}
