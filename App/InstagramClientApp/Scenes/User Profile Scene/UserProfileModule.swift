//
//  UserProfileModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 14/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Firebase
import InstagramEngine

final class UserProfileModule {
    private let router: UserProfileRouter
    private let viewController: UserProfileViewController
    private let profileService: UserProfileService
    private let postService: PostService
    private let presenter: UserProfilePresenter
    private let profileUseCase: UserProfileUseCase
    private let postUseCase: HomeFeedUseCase
    
    var withNavigation: UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
    
    init() {
        self.router = UserProfileRouter()
        let cacheManager = CacheManager()
        viewController = UserProfileViewController(router: router, cacheManager: cacheManager)
        profileService = UserProfileService(firebaseAuth: Auth.self,
                                     firebaseDatabase: Database.self,
                                     networking: URLSession.shared)
        postService = PostService(firebaseAuth: Auth.self,
                                  firebaseDatabase: Database.self,
                                  networking: URLSession.shared,
                                  profileService: profileService)
        presenter = UserProfilePresenter(view: WeakRef(viewController))
        profileUseCase = UserProfileUseCase(client: profileService, output: presenter)
        postUseCase = HomeFeedUseCase(client: postService, output: presenter)
        
        router.viewControllerBehind = viewController
        
        viewController.loadProfile = profileUseCase.loadProfile
        viewController.downloadProfileImage = profileUseCase.downloadProfileImage
        viewController.logout = profileUseCase.logout
        viewController.loadPosts = postUseCase.loadPosts
        viewController.downloadPostImage = postUseCase.downloadPostImage
    }
}
