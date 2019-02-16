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
        viewController = HomeFeedViewController(router: router)
        let networking = URLSessionManager()
        profileService = UserProfileService(firebaseAuth: Auth.self,
                                            firebaseDatabase: Database.self,
                                            networking: networking)
        service = PostService(firebaseAuth: Auth.self,
                              firebaseDatabase: Database.self,
                              networking: networking,
                              profileService: profileService)
        presenter = HomeFeedPresenter(view: WeakRef(viewController))
        useCase = HomeFeedUseCase(postClient: service, output: presenter)
        
//        viewController.getPostsCount = useCase.getPostsCount
//        viewController.loadNewPosts = useCase.loadNewPosts
//        viewController.downloadPostImage = useCase.downloadPostImage
//        viewController.downloadProfileImage = profileService.downloadProfileImage
        viewController.loadAllPosts = useCase.loadAllPosts
        viewController.changeLikes = useCase.changeLikes
        
        let postImageFetchService = AsyncFetchService(operationType: ImageDownloadOperation.self, networking: networking)
        viewController.loadPostImage = postImageFetchService.startFetch
        viewController.cancelLoadPostImage = postImageFetchService.cancelFetch
        viewController.getCachedPostImage = postImageFetchService.fetchedData
        
        let profileImageFetchService = AsyncFetchService(operationType: ImageDownloadOperation.self, networking: networking)
        viewController.loadProfileImage = profileImageFetchService.startFetch
        viewController.cancelLoadProfileImage = profileImageFetchService.cancelFetch
        viewController.getCachedProfileImage = profileImageFetchService.fetchedData
        
        router.viewController = viewController
    }
}
