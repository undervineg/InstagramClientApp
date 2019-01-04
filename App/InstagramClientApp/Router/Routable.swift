//
//  Router.swift
//  InstagramClientApp
//
//  Created by 심승민 on 03/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol Routable: class {
    associatedtype T: UIViewController
    var viewControllerBehind: T? { get }
    
    func open(_ viewController: UIViewController, with transition: Transition)
}
