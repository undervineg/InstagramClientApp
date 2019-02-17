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
        let networking = URLSessionManager()
        viewController = UserProfileViewController(router: router)
        profileService = UserProfileService(firebaseAuth: Auth.self,
                                     firebaseDatabase: Database.self,
                                     networking: networking)
        loginService = LoginService(auth: Auth.self)
        postService = PostService(firebaseAuth: Auth.self,
                                  firebaseDatabase: Database.self,
                                  networking: networking,
                                  profileService: profileService)
        presenter = UserProfilePresenter(view: WeakRef(viewController))
        useCase = UserProfileUseCase(client: profileService, output: presenter, loginClient: loginService, postClient: postService)
        
        router.viewController = viewController
        
        viewController.loadProfile = useCase.loadProfile
        viewController.loadSummaryCounts = useCase.loadSummaryCounts
        viewController.logout = useCase.logout
        viewController.loadPaginatePosts = (useCase as FeaturePostLoadable).loadPaginatePosts
        viewController.follow = useCase.followUser
        viewController.unfollow = useCase.unfollowUser
        viewController.checkCurrentUserIsFollowing = useCase.checkIsFollowing
        
        let postImageFetchService = AsyncFetchService(operationType: ImageDownloadOperation.self, networking: networking)
        viewController.loadPostImage = postImageFetchService.startFetch
        viewController.cancelLoadPostImage = postImageFetchService.cancelFetch
        viewController.getCachedPostImage = postImageFetchService.fetchedData
        
        let profileImageFetchService = AsyncFetchService(operationType: ImageDownloadOperation.self, networking: networking)
        viewController.loadProfileImage = profileImageFetchService.startFetch
        viewController.cancelLoadProfileImage = profileImageFetchService.cancelFetch
        viewController.getCachedProfileImage = profileImageFetchService.fetchedData
    }
}
