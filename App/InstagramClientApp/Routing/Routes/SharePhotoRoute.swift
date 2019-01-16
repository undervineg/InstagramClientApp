//
//  SharePhotoRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

protocol SharePhotoRoute {
    var sharePhotoTransition: TransitionType { get }
    
    func openSharePhotoPage()
    func closePhotoSelectorPage()
}
