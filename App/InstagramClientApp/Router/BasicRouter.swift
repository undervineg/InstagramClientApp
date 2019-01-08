//
//  BasicRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

class BasicRouter: Routable, Closable {
    weak var viewControllerBehind: UIViewController?
    
    private var transition: Transition?
    
    func open(_ viewController: UIViewController, with transition: Transition) {
        self.transition = transition
        transition.viewControllerBehind = self.viewControllerBehind
        transition.open(viewController)
    }
    
    func close(to destination: UIViewController? = nil) {
        if let destinationVC = destination {
            self.transition?.close(destinationVC)
        } else {
            self.transition?.close(nil)
        }
    }
}
