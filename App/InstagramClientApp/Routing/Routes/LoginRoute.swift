//
//  LoginRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

protocol LoginRoute {
    var loginTransition: TransitionType { get }
    
    func openLoginPage()
}
