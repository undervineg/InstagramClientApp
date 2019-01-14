//
//  AuthRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 14/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class AuthRouter: BasicRouter, AuthRouter.Routes {
    typealias Routes = LoginRouter.Routes & RegisterRouter.Routes
}

final class LoginRouter: BasicRouter, LoginRouter.Routes {
    typealias Routes = MainRoute & RegisterRoute
}

final class RegisterRouter: BasicRouter, RegisterRouter.Routes {
    typealias Routes = MainRoute & LoginRoute
}
