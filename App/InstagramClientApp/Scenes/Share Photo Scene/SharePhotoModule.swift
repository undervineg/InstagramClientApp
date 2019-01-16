//
//  SharePhotoModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import Firebase
import InstagramEngine

final class SharePhotoModule {
    let router: SharePhotoRouter
    let viewController: SharePhotoViewController
    private let service: ShareService
    private let presenter: SharePhotoPresenter
    private let useCase: SharePhotoUseCase
    
    init(_ selectedImage: UIImage) {
        router = SharePhotoRouter()
        viewController = SharePhotoViewController(router: router, selectedImage: selectedImage)
        service = ShareService(storage: Storage.self, database: Database.self, auth: Auth.self)
        presenter = SharePhotoPresenter(view: viewController)
        useCase = SharePhotoUseCase(client: service, output: presenter)
        
        router.viewControllerBehind = viewController
        
        viewController.share = useCase.share
    }
}
