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
    var viewControllerBehind: UIViewController?
    
    var openedVC = [UIViewController]()
    var closedVC = [UIViewController]()
    
    func open(_ viewController: UIViewController) {
        if viewControllerBehind != nil {
            openedVC.append(viewController)
        }
    }
    
    func close() {
        guard viewControllerBehind != nil else { return }
        let removedVC = openedVC.removeLast()
        closedVC.append(removedVC)
    }
    
    func close(to destVC: UIViewController) {
        guard viewControllerBehind != nil else { return }
        openedVC.reversed().forEach {
            guard $0 != destVC else { return }
            let removedVC = openedVC.removeLast()
            closedVC.append(removedVC)
        }
    }
}
