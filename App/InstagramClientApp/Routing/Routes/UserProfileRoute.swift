//
//  UserProfileRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 20/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

protocol UserProfileRoute {
    var userProfileTransition: TransitionType { get }
    
    func openUserProfilePage(of uid: String)
    func openUserProfilePage(of uid: String, with transition: TransitionType)
}
