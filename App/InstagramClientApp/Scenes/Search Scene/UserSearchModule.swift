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
    let viewController: UserSearchViewController
    private let service: UserProfileService
    private let presenter: UserSearchPresenter
    private let useCase: SearchUseCase
    
    var withNavigation: UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
    
    init() {
        let cacheManager = CacheManager()
        viewController = UserSearchViewController(cacheManager: cacheManager)
        service = UserProfileService(firebaseAuth: Auth.self,
                                     firebaseDatabase: Database.self,
                                     networking: URLSession.shared)
        presenter = UserSearchPresenter(view: viewController)
        useCase = SearchUseCase(client: service, output: presenter)
        
        viewController.fetchAllUsers = useCase.fetchAllUsers
        viewController.downloadProfileImage = service.downloadProfileImage
    }
}
