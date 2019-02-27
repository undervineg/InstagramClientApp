//
//  SearchModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import Firebase
import InstagramEngine

final class UserSearchModule {
    let router: UserSearchRouter
    let viewController: UserSearchViewController
    private let service: UserProfileService
    private let presenter: UserSearchPresenter
    private let useCase: SearchUseCase
    
    var withNavigation: UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
    
    init() {
        let networking = URLSessionManager()
        router = UserSearchRouter()
        viewController = UserSearchViewController(router: router)
        service = UserProfileService(firebaseAuth: Auth.self,
                                     firebaseDatabase: Database.self,
                                     firebaseMessaging: Messaging.self,
                                     networking: networking)
        presenter = UserSearchPresenter(view: WeakRef(viewController))
        useCase = SearchUseCase(client: service, output: presenter)
        
        router.viewController = viewController
        
        viewController.fetchAllUsers = useCase.fetchAllUsers
        
        let profileImageFetchService = AsyncFetchService(operationType: ImageDownloadOperation.self,
                                                         networking: networking)
        viewController.loadProfileImage = profileImageFetchService.startFetch
        viewController.cancelLoadProfileImage = profileImageFetchService.cancelFetch
        viewController.getCachedProfileImage = profileImageFetchService.fetchedData
    }
}
