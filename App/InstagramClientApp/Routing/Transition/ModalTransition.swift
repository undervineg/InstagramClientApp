//
//  ModalTransition.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class ModalTransition: NSObject, Transition {
    weak var viewController: UIViewController?
    
    private var animator: Animator?
    private let animated: Bool
    var completion: (() -> Void)?
    
    init(animated: Bool = true, animator: Animator? = nil) {
        self.animated = animated
        self.animator = animator
    }
    
    func open(_ viewController: UIViewController) {
        viewController.transitioningDelegate = self
        self.viewController?.present(viewController, animated: animated, completion: completion)
    }
    
    func close(_ viewController: UIViewController) {
        viewController.transitioningDelegate = self
        viewController.dismiss(animated: animated, completion: completion)
    }
}

extension ModalTransition: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator?.isPresenting = false
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator?.isPresenting = true
        return animator
    }
}
