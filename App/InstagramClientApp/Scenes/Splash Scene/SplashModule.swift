//
//  SplashModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 14/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseAuth
import InstagramEngine

final class SplashModule {
    let router: SplashRouter
    let viewController: SplashViewController
    private let service: AuthService
    private let presenter: SplashPresenter
    private let useCase: AuthUseCase
    
    init() {
        router = SplashRouter()
        viewController = SplashViewController(router: router)
        service = AuthService(auth: Auth.self)
        presenter = SplashPresenter(view: WeakRef(viewController))
        useCase = AuthUseCase(client: service, output: presenter)
        
        router.viewControllerBehind = viewController
        
        viewController.checkIfAuthenticated = useCase.checkIfAuthenticated
    }
}
