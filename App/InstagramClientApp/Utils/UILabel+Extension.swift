//
//  UILabel+Extension.swift
//  InstagramClientApp
//
//  Created by 심승민 on 24/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

extension UILabel {
    func bounceToAppear(_ completion: @escaping () -> Void) {
        self.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }) { (completed) in
            completion()
        }
    }
    
    func bounceToDisappear(_ completion: @escaping () -> Void) {
        self.layer.transform = CATransform3DMakeScale(1, 1, 1)
        
        UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
            self.alpha = 0
        }, completion: { (completed) in
            completion()
        })
    }
}

