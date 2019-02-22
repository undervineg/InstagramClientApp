//
//  NotificationModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 21/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

final class LikesModule {
    let viewController: NotificationViewController
    private let service: NotificationService
    private let presenter: SplashPresenter
    private let useCase: AuthUseCase
    
    init() {
        let networking = URLSessionManager()
        lazy var profileService = UserProfileService(firebaseAuth: Auth.self, firebaseDatabase: Database.self, networking: networking)
        lazy var service = NotificationService(database: Database.self,
                                               auth: Auth.self,
                                               profileService: profileService,
                                               postService: PostService(firebaseAuth: Auth.self, firebaseDatabase: Database.self, networking: networking, profileService: profileService))
    }
}
