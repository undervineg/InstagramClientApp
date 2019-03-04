//
//  SharePhotoRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol SharePhotoRoute {
    var sharePhotoTransition: Transition { get }
    
    func openSharePhotoPage(with selectedImage: UIImage)
    func closePhotoSelectorPage()
}
