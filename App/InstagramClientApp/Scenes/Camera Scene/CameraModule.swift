//
//  CameraModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

final class CameraModule {
    let viewController: CameraViewController
    let router: CameraRouter
    
    init() {
        router = CameraRouter()
        viewController = CameraViewController(router: router)
        
        router.viewControllerBehind = viewController
    }
}
