//
//  ModalTransition.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class ModalTransition: Transition {
    weak var viewControllerBehind: UIViewController?
    
    private let animated: Bool
    private let completion: (() -> Void)?
    
    init(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.animated = animated
        self.completion = completion
    }
    
    func open(_ viewController: UIViewController) {
        self.viewControllerBehind?.present(viewController, animated: animated, completion: completion)
    }
    
    func close() {
        self.viewControllerBehind?.dismiss(animated: animated, completion: completion)
    }
    
    func close(to destVC: UIViewController) {
        destVC.presentingViewController?.dismiss(animated: animated, completion: completion)
    }
}
