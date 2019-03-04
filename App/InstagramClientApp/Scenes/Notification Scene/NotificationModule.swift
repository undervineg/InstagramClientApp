//
//  NotificationModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 21/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine
import Firebase

final class NotificationModule {
    let containerViewController: NotificationContainerController
    private let myNewsViewController: MyNewsViewController
    private let followingNewsViewController: FollowingNewsViewController
    
    init() {
        let networking = URLSessionManager()
        let profileService = UserProfileService(firebaseAuth: Auth.self,
                                                firebaseDatabase: Database.self,
                                                firebaseMessaging: Messaging.self,
                                                networking: networking)
        let postService = PostService(firebaseAuth: Auth.self, firebaseDatabase: Database.self, networking: networking, profileService: profileService)
        let postImageFetchService = AsyncFetchService(operationType: ImageDownloadOperation.self, networking: networking)
        let profileImageFetchService = AsyncFetchService(operationType: ImageDownloadOperation.self, networking: networking)
        let newsService = NotificationService(database: Database.self,
                                              auth: Auth.self,
                                              profileService: profileService,
                                              postService: postService)
        
        self.myNewsViewController = MyNewsViewController()
        let myNewsPresenter = NotificationPresenter(view: WeakRef(myNewsViewController))
        let myNewsUseCase = NotificationUseCase(client: newsService, output: myNewsPresenter)
        
        self.myNewsViewController.loadAllNotifications = myNewsUseCase.loadAllNotifications
        
        self.myNewsViewController.loadProfileImage = profileImageFetchService.startFetch
        self.myNewsViewController.cancelLoadProfileImage = profileImageFetchService.cancelFetch
        self.myNewsViewController.getCachedProfileImage = profileImageFetchService.fetchedData
        
        self.myNewsViewController.loadPostImage = postImageFetchService.startFetch
        self.myNewsViewController.cancelLoadPostImage = postImageFetchService.cancelFetch
        self.myNewsViewController.getCachedPostImage = postImageFetchService.fetchedData
        
        self.followingNewsViewController = FollowingNewsViewController()
        let followingNewsPresenter = NotificationPresenter(view: WeakRef(followingNewsViewController))
        let followingNewsUseCase = NotificationUseCase(client: newsService, output: followingNewsPresenter)
        
        self.followingNewsViewController.loadAllNotifications = followingNewsUseCase.loadAllNotifications
        
        self.followingNewsViewController.loadProfileImage = profileImageFetchService.startFetch
        self.followingNewsViewController.cancelLoadProfileImage = profileImageFetchService.cancelFetch
        self.followingNewsViewController.getCachedProfileImage = profileImageFetchService.fetchedData
        
        self.followingNewsViewController.loadPostImage = postImageFetchService.startFetch
        self.followingNewsViewController.cancelLoadPostImage = postImageFetchService.cancelFetch
        self.followingNewsViewController.getCachedPostImage = postImageFetchService.fetchedData
        
        self.containerViewController = NotificationContainerController(followingNewsViewController,
                                                                       myNewsViewController)
    }
}
