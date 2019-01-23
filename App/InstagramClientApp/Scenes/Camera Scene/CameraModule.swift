//
//  CameraModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine
import Photos

final class CameraModule {
    let viewController: CameraViewController
    let router: CameraRouter
    private let service: PhotoService
    private let useCase: PhotoUseCase
    
    init() {
        router = CameraRouter()
        viewController = CameraViewController(router: router)
        service = PhotoService(photos: PHAsset.self)
        useCase = PhotoUseCase(client: service, output: viewController)
        
        viewController.saveCapturedPhoto = useCase.savePhoto
        
        router.viewControllerBehind = viewController
    }
}
