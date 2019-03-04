//
//  CommentsModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 25/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine
import Firebase
import UIKit

final class CommentsModule {
    let viewController: CommentsViewController
    private let presenter: CommentsPresenter
    private let profileService: UserProfileService
    private let service: CommentsService
    private let useCase: CommentsUseCase
    
    init(postId: String) {
        let networking = URLSessionManager()
        viewController = CommentsViewController(currentPostId: postId)
        presenter = CommentsPresenter(view: WeakRef(viewController))
        profileService = UserProfileService(firebaseAuth: Auth.self,
                                            firebaseDatabase: Database.self,
                                            firebaseMessaging: Messaging.self,
                                            networking: networking)
        service = CommentsService(database: Database.self, auth: Auth.self, profileService: profileService)
        useCase = CommentsUseCase(client: service, output: presenter)
        
        viewController.submitComment = useCase.saveComment
        viewController.loadCommentsForPost = useCase.loadComments
        
        let profileImageFetchService = AsyncFetchService(operationType: ImageDownloadOperation.self, networking: networking)
        viewController.loadProfileImage = profileImageFetchService.startFetch
        viewController.cancelLoadProfileImage = profileImageFetchService.cancelFetch
        viewController.getCachedProfileImage = profileImageFetchService.fetchedData
    }
}
