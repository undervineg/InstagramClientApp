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
        let imageFetchService = AsyncFetchService(operationType: RawImageDownloadOperation.self, networking: networking)
        let newsService = NotificationService(database: Database.self,
                                              auth: Auth.self,
                                              profileService: profileService,
                                              postService: postService)
        
        self.myNewsViewController = MyNewsViewController()
        let myNewsPresenter = NotificationPresenter(view: WeakRef(myNewsViewController))
        let myNewsUseCase = NotificationUseCase(client: newsService, output: myNewsPresenter)
        
        self.myNewsViewController.loadAllNotifications = myNewsUseCase.loadAllNotifications
        self.myNewsViewController.loadProfileImage = imageFetchService.startFetch
        self.myNewsViewController.cancelLoadProfileImage = imageFetchService.cancelFetch
        self.myNewsViewController.getCachedProfileImage = imageFetchService.fetchedData
        
        self.followingNewsViewController = FollowingNewsViewController()
        let followingNewsPresenter = NotificationPresenter(view: WeakRef(followingNewsViewController))
        let followingNewsUseCase = NotificationUseCase(client: newsService, output: followingNewsPresenter)
        
        self.followingNewsViewController.loadAllNotifications = followingNewsUseCase.loadAllNotifications
        self.followingNewsViewController.loadProfileImage = imageFetchService.startFetch
        self.followingNewsViewController.cancelLoadProfileImage = imageFetchService.cancelFetch
        self.followingNewsViewController.getCachedProfileImage = imageFetchService.fetchedData
        
        self.containerViewController = NotificationContainerController(followingNewsViewController,
                                                                       myNewsViewController)
    }
}
