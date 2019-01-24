//
//  BasicRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol Routable: class {
    var viewController: UIViewController? { get }
    
    func open(_ viewController: UIViewController, with transition: Transition)
}

protocol Closable: class {
    func close()
}

class BasicRouter: Routable, Closable {
    weak var viewController: UIViewController?
    
    var openTransition: Transition?
    
    func open(_ viewController: UIViewController, with transition: Transition) {
        transition.viewController = self.viewController
        transition.open(viewController)
    }
    
    func close() {
        guard let viewController = viewController else { return }
        openTransition?.close(viewController)
    }
}
