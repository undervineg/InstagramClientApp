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
    private let router: UserProfileRouter
    private let viewController: UserProfileViewController
    private let service: UserProfileService
    private let presenter: UserProfilePresenter
    private let useCase: UserProfileUseCase
    
    var withNavigation: UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
    
    init() {
        self.router = UserProfileRouter()
        viewController = UserProfileViewController(router: router)
        service = UserProfileService(firebaseAuth: Auth.self,
                                     firebaseDatabase: Database.self,
                                     firebaseStorage: Storage.self,
                                     networking: URLSession.shared)
        presenter = UserProfilePresenter(view: WeakRef(viewController))
        useCase = UserProfileUseCase(client: service, output: presenter)
        
        router.viewControllerBehind = viewController
        
        viewController.loadProfile = useCase.loadProfile
        viewController.downloadProfileImage = useCase.downloadProfileImage
        viewController.logout = useCase.logout
        viewController.loadPosts = useCase.loadPosts
        viewController.downloadPostImage = useCase.downloadPostImage
    }
}
