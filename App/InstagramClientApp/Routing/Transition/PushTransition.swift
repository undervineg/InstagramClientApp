//
//  PushTransition.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class PushTransition: Transition {
    
    weak var viewControllerBehind: UIViewController?
    
    private let animated: Bool
    private let completion: (() -> Void)?
    
    init(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.animated = animated
        self.completion = completion
    }
    
    func open(_ viewController: UIViewController) {
        viewControllerBehind?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func close() {
        viewControllerBehind?.navigationController?.popViewController(animated: animated)
    }
    
    func close(to destVC: UIViewController) {
        viewControllerBehind?.navigationController?.popToViewController(destVC, animated: animated)
    }
}
