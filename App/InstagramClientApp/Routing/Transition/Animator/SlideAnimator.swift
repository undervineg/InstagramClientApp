//
//  PushAnimator.swift
//  InstagramClientApp
//
//  Created by 심승민 on 23/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class SlideAnimator: NSObject, Animator {
    var isPresenting: Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresenting ? dismissWithSlide(using: transitionContext) : presentWithSlide(using: transitionContext)
    }
    
    private func presentWithSlide(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) else { return }
        
        transitionContext.containerView.addSubview(toView)
        
        let startOrigin = CGPoint(x: -toView.frame.width, y: 0)
        
        toView.frame.origin = startOrigin
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            toView.frame.origin = CGPoint(x: 0, y: 0)
            fromView.frame.origin = CGPoint(x: fromView.frame.width, y: 0)
            
        }) { (completed) in
            transitionContext.completeTransition(true)
        }
    }
    
    private func dismissWithSlide(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(toView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            fromView.frame.origin = CGPoint(x: -fromView.frame.width, y: 0)
            toView.frame.origin = CGPoint(x: 0, y: 0)
            
        }) { (completed) in
            transitionContext.completeTransition(true)
        }
    }
}
