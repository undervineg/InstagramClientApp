//
//  BasicRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol Routable: class {
    var viewControllerBehind: UIViewController? { get }
    
    func open(_ viewController: UIViewController, with transition: Transition)
}

protocol Closable: class {
    func close()
    func close(to destVC: UIViewController)
}

class BasicRouter: Routable, Closable {
    weak var viewControllerBehind: UIViewController?
    
    var openTransition: Transition?
    
    func open(_ viewController: UIViewController, with transition: Transition) {
        transition.viewControllerBehind = self.viewControllerBehind
        transition.open(viewController)
    }
    
    func close() {
        openTransition?.close()
    }
    
    func close(to destVC: UIViewController) {
        openTransition?.close(to: destVC)
    }
}
