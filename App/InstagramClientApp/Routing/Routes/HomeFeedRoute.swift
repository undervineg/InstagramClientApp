//
//  HomeFeedRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

protocol HomeFeedRoute {
    var homeTransitionType: TransitionType { get }
    
    func openHomeFeedPage()
    func openHomeFeedPage(with transitionType: TransitionType)
}
