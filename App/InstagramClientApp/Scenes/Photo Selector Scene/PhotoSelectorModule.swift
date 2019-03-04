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
    let router: PhotoSelectorRouter
    let viewController: PhotoSelectorViewController
    private let service: PhotoService
    
    var withNavigation: UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
    
    init() {
        self.router = PhotoSelectorRouter()
        viewController = PhotoSelectorViewController(router: router)
        let photoManager = PhotosManager()
        photoManager.photoLibraryChangeHandler = viewController.handlePhotoLibraryChanges
        service = PhotoService(photos: photoManager)
        
        router.viewController = viewController

        viewController.assetCount = service.assetCount
        viewController.loadAllPhotos = service.fetchAllPhotos
        viewController.startCachingPhotos = service.startCachingPhotos
        viewController.stopCachingPhotos = service.stopCachingPhotos
        viewController.resetCachedPhotos = service.resetCache
        viewController.requestImage = service.requestImage
        viewController.assetInfo = service.getAssetInfo
    }
}
