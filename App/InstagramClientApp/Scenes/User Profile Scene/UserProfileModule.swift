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
    let router: UserProfileRouter
    let viewController: UserProfileViewController
    private let profileService: UserProfileService
    private let loginService: LoginService
    private let postService: PostService
    private let presenter: UserProfilePresenter
    private let useCase: UserProfileUseCase
    
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
        loginService = LoginService(auth: Auth.self)
        postService = PostService(firebaseAuth: Auth.self,
                                  firebaseDatabase: Database.self,
                                  networking: URLSession.shared,
                                  profileService: profileService)
        presenter = UserProfilePresenter(view: WeakRef(viewController))
        useCase = UserProfileUseCase(client: profileService, output: presenter, loginClient: loginService, postClient: postService)
        
        router.viewController = viewController
        
        viewController.loadProfile = useCase.loadProfile
        viewController.loadSummaryCounts = useCase.loadSummaryCounts
        viewController.downloadProfileImage = useCase.downloadProfileImage
        viewController.logout = useCase.logout
        viewController.loadPaginatePosts = (useCase as FeaturePostLoadable).loadPaginatePosts
        viewController.downloadPostImage = (useCase as FeaturePostLoadable).downloadPostImage
        viewController.follow = useCase.followUser
        viewController.unfollow = useCase.unfollowUser
        viewController.checkIsFollowing = useCase.checkIsFollowing
    }
}
