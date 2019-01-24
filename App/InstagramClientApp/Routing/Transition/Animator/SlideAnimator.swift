//
//  PushAnimator.swift
//  InstagramClientApp
//
//  Created by 심승민 on 23/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class SlideAnimator: NSObject, Animator {
    var isPresenting: Bool = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
    }
    
    private func presentWithSlide() {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        containerView.addSubview(toView)
        
        let startingOrigin = CGPoint(x: -toView.frame.width, y: 0)
        
        toView.frame.origin = startingOrigin
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            toView.frame.origin = CGPoint(x: 0, y: 0)
            
        }) { (completed) in
            transitionContext.completeTransition(true)
        }
    }
}
