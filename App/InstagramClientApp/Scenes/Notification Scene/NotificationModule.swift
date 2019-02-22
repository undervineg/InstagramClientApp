//
//  NotificationModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 21/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine
import FirebaseAuth
import FirebaseDatabase

final class NotificationModule {
    let containerViewController: NotificationContainerController
    private let myNewsViewController: MyNewsViewController
    private let followingNewsViewController: FollowingNewsViewController
    private let service: NotificationService
    private let presenter: NotificationPresenter
    private let useCase: NotificationUseCase
    
    init() {
        let networking = URLSessionManager()
        let profileService = UserProfileService(firebaseAuth: Auth.self, firebaseDatabase: Database.self, networking: networking)
        let postService = PostService(firebaseAuth: Auth.self, firebaseDatabase: Database.self, networking: networking, profileService: profileService)
        self.service = NotificationService(database: Database.self,
                                           auth: Auth.self,
                                           profileService: profileService,
                                           postService: postService)
        self.myNewsViewController = MyNewsViewController()
        self.presenter = NotificationPresenter(view: WeakRef(myNewsViewController))
        self.useCase = NotificationUseCase(client: service, output: presenter)
        
        myNewsViewController.loadAllNotifications = useCase.loadAllNotifications
        
        let profileImageFetchService = AsyncFetchService(operationType: ImageDownloadOperation.self, networking: networking)
        myNewsViewController.loadProfileImage = profileImageFetchService.startFetch
        myNewsViewController.cancelLoadProfileImage = profileImageFetchService.cancelFetch
        myNewsViewController.getCachedProfileImage = profileImageFetchService.fetchedData
        
        followingNewsViewController = FollowingNewsViewController()
        
        containerViewController = NotificationContainerController(followingNewsViewController, myNewsViewController)
    }
}
