//
//  TransitinoStub.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
@testable import InstagramClientApp

final class StubTransition: Transition {
    var viewController: UIViewController?
    
    var openedVC = [UIViewController]()
    var closedVC = [UIViewController]()
    
    func open(_ viewController: UIViewController) {
        if self.viewController != nil {
            openedVC.append(viewController)
        }
    }
    
    func close(_ viewController: UIViewController) {
        guard self.viewController != nil else { return }
        let removedVC = openedVC.removeLast()
        closedVC.append(removedVC)
    }
}
