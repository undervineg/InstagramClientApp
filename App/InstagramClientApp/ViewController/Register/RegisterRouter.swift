//
//  RegisterRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

final class RegisterRouter: BasicRouter, RegisterRouter.Routes {
    typealias Routes = LoginRoute & ImagePickerRoute
}
