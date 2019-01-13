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
    func loginViewController(router: LoginRouter.Routes) -> UIViewController
    func userProfileViewController(router: MainRouter.Routes) -> UIViewController
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
        let profileVC = self.userProfileViewController(router: router)
        let profileNavigation = UINavigationController(rootViewController: profileVC)
        
        let vc = MainTabBarViewController(subViewControllers: [profileNavigation])
        
        vc.selectedIndex = 0
        
        return vc
    }
    
    func registerViewController(router: RegisterRouter.Routes) -> UIViewController {
        let vc = RegisterUserViewController(router: router)
        let service = RegisterUserService(firebaseAuth: Auth.self,
                                          firebaseDatabase: Database.self,
                                          firebaseStorage: Storage.self)
        let presenter = RegisterUserPresenter(view: WeakRef(vc))
        let useCase = RegisterUserUseCase(client: service, output: presenter)
        
        vc.register = useCase.register
        
        return vc
    }
    
    func loginViewController(router: LoginRouter.Routes) -> UIViewController {
        let vc = LoginViewController(router: router)
        let service = LoginService(auth: Auth.self)
        let output = LoginPresenter(view: vc)
        let useCase = LoginUseCase(client: service, output: output)
        
        vc.login = useCase.login
        
        return vc
    }
    
    func userProfileViewController(router: MainRouter.Routes) -> UIViewController {
        let vc = UserProfileViewController(router: router)
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
