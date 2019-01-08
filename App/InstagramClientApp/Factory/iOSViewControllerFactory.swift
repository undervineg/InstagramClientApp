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
    func registerViewController(router: RegisterRouter.Routes) -> UIViewController
}

final class iOSViewControllerFactory: ViewControllerFactory {
    
    func registerViewController(router: RegisterRouter.Routes) -> UIViewController {
        let vc = RegisterUserViewController(router: router)
        let adapter = RegisterUserClientAdapter(firebaseAuth: Auth.self,
                                                firebaseDatabase: Database.self,
                                                firebaseStorage: Storage.self)
        let presenter = RegisterUserPresenter(view: WeakRef(vc))
        let useCase = RegisterUserUseCase(client: adapter, output: presenter)
        
        vc.registerCallback = useCase.register
        
        return vc
    }
}
