//
//  MainRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol MainRoute {
    var mainTransition: Transition { get }
    
    func openMainPage()
    func openMainPage(with transition: Transition)
    func openMainPageAsRoot(_ callback: (UIViewController) -> Void)
}
