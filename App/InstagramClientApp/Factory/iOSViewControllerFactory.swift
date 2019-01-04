//
//  iOSViewControllerFactory.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

protocol ViewControllerFactory {
    func registerViewController(registerCallback: @escaping (String, String, String, @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) -> ()) -> UIViewController
}

final class iOSViewControllerFactory: ViewControllerFactory {
    
    func registerViewController(registerCallback callback: @escaping (String, String, String, @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) -> ()) -> UIViewController {
        return RegisterUserViewController(registerCallback: callback)
    }
}
