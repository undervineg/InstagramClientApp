//
//  iOSViewControllerFactory.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import Firebase
import InstagramEngine

protocol ViewControllerFactory {
    func splashViewController(router: SplashRouter.Routes) -> UIViewController
    func mainViewController(router: MainRouter.Routes) -> UIViewController
    func registerViewController(router: RegisterRouter.Routes) -> UIViewController
    func userProfileViewController() -> UIViewController
}

final class iOSViewControllerFactory: ViewControllerFactory {
    
    func splashViewController(router: SplashRouter.Routes) -> UIViewController {
        let vc = SplashViewController(router: router)
        let service = AuthService(auth: Auth.self)
        let presenter = SplashPresenter(view: WeakRef(vc))
        let useCase = AuthUseCase(client: service, output: presenter)
        
        vc.checkIfAuthenticated = useCase.checkIfAuthenticated
        
        return vc
    }
    
    func mainViewController(router: MainRouter.Routes) -> UIViewController {
        let profileVC = userProfileViewController()
        let profileNavigation = UINavigationController(rootViewController: profileVC)
        
        let mainTabBarVC = MainTabBarViewController(router: router, subViewControllers: [profileNavigation])
        
        mainTabBarVC.selectedIndex = 0
        
        return mainTabBarVC
    }
    
    func registerViewController(router: RegisterRouter.Routes) -> UIViewController {
        let vc = RegisterUserViewController(router: router)
        let service = RegisterUserService(firebaseAuth: Auth.self,
                                          firebaseDatabase: Database.self,
                                          firebaseStorage: Storage.self)
        let presenter = RegisterUserPresenter(view: WeakRef(vc))
        let useCase = RegisterUserUseCase(client: service, output: presenter)
        
        vc.registerCallback = useCase.register
        
        return vc
    }
    
    func userProfileViewController() -> UIViewController {
        let router = UserProfileRouter()
        let vc = UserProfileViewController(router: router)
        router.viewControllerBehind = vc
        let service = UserProfileService(firebaseAuth: Auth.self,
                                         firebaseDatabase: Database.self,
                                         firebaseStorage: Storage.self,
                                         networking: URLSession.shared)
        let presenter = UserProfilePresenter(view: WeakRef(vc))
        let useCase = UserProfileUseCase(client: service, output: presenter)
        
        vc.loadProfile = useCase.loadProfile
        vc.downloadProfileImage = useCase.downloadProfileImage
        vc.logout = useCase.logout
        
        return vc
    }
}
