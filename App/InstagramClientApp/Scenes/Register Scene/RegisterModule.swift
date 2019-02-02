//
//  RegisterModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 14/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Firebase
import InstagramEngine

final class RegisterModule {
    let router: RegisterRouter
    let viewController: RegisterUserViewController
    private let service: RegisterUserService
    private let presenter: RegisterUserPresenter
    private let useCase: RegisterUserUseCase
    
    var withNavigation: UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
    
    init() {
        self.router = RegisterRouter()
        viewController = RegisterUserViewController(router: router)
        service = RegisterUserService(firebaseAuth: Auth.self,
                                      firebaseDatabase: Database.self,
                                      firebaseStorage: Storage.self,
                                      firebaseMessaging: Messaging.self)
        presenter = RegisterUserPresenter(view: WeakRef(viewController))
        useCase = RegisterUserUseCase(client: service, output: presenter)
        
        router.viewController = viewController
        
        viewController.register = useCase.register
    }
}
