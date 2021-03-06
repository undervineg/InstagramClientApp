//
//  Animator.swift
//  InstagramClientApp
//
//  Created by 심승민 on 23/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol Animator: UIViewControllerAnimatedTransitioning {
    var isPresenting: Bool { get set }
}
