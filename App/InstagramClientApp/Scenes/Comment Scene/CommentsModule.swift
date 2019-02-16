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
        let cacheManager = CacheManager()
        viewController = CommentsViewController(currentPostId: postId, cacheManager: cacheManager)
        presenter = CommentsPresenter(view: WeakRef(viewController))
        profileService = UserProfileService(firebaseAuth: Auth.self,
                                            firebaseDatabase: Database.self,
                                            networking: URLSessionManager())
        service = CommentsService(database: Database.self, auth: Auth.self, profileService: profileService)
        useCase = CommentsUseCase(client: service, output: presenter)
        
        viewController.submitComment = useCase.saveComment
        viewController.loadCommentsForPost = useCase.loadComments
        viewController.downloadProfileImage = profileService.downloadProfileImage
    }
}
