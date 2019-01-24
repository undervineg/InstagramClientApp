//
//  HomeModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import Firebase
import InstagramEngine

final class HomeModule {
    let viewController: HomeFeedViewController
    let router: HomeFeedRouter
    private let service: PostService
    private let profileService: UserProfileService
    private let presenter: HomeFeedPresenter
    private let useCase: HomeFeedUseCase
    
    var withNavigation: UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
    
    init() {
        router = HomeFeedRouter()
        let cacheManager = CacheManager()
        viewController = HomeFeedViewController(router: router, cacheManager: cacheManager)
        profileService = UserProfileService(firebaseAuth: Auth.self,
                                            firebaseDatabase: Database.self,
                                            networking: URLSession.shared)
        service = PostService(firebaseAuth: Auth.self,
                              firebaseDatabase: Database.self,
                              networking: URLSession.shared,
                              profileService: profileService)
        presenter = HomeFeedPresenter(view: WeakRef(viewController))
        useCase = HomeFeedUseCase(postClient: service, profileClient: profileService, output: presenter)
        
        viewController.loadAllPosts = useCase.loadAllPosts
        viewController.downloadPostImage = useCase.downloadPostImage
        viewController.downloadProfileImage = profileService.downloadProfileImage
        
        router.viewController = viewController
    }
}
