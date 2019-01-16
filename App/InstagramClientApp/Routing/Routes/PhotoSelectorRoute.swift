//
//  PhotoSelectorRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

protocol PhotoSelectorRoute {
    var photoSelectorTransition: TransitionType { get }
    var sharePhotoTransition: TransitionType { get }
    
    func openPhotoSelectorPage()
    func closePhotoSelectorPage()
    func openSharePhotoPage()
    func closeSharePhotoPage()
}
