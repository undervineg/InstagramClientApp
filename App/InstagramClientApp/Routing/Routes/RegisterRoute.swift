//
//  RegisterRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol RegisterRoute {
    var registerTransition: Transition { get }
    
    func openRegisterPage()
    func openRegisterPage(with transition: Transition)
    func openRegisterPageAsRoot(_ callback: (UIViewController) -> Void)
}
