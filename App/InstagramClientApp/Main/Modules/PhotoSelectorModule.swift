//
//  PhotoSelectorModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import Photos
import InstagramEngine

final class PhotoSelectorModule {
    let router: MainRouter
    let viewController: PhotoSelectorViewController
    private let service: PhotoService
    private let presenter: PhotoSelectorPresenter
    private let useCase: LoadPhotoUseCase
    
    var withNavigation: UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
    
    init(router: MainRouter) {
        self.router = router
        viewController = PhotoSelectorViewController(router: router)
        service = PhotoService(photos: PHAsset.self)
        presenter = PhotoSelectorPresenter(view: WeakRef(viewController))
        useCase = LoadPhotoUseCase(client: service, output: presenter)
        
        viewController.fetchAllPhotos = useCase.fetchAllPhotos
    }
}