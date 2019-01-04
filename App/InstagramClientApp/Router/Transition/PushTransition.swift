//
//  PushTransition.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class PushTransition: Transition {
    #warning("Should insert viewControllerBehind")
    weak var viewControllerBehind: UIViewController?
    
    private let animated: Bool
    private let completion: (() -> Void)?
    
    init(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.animated = animated
        self.completion = completion
    }
    
    func open(_ viewController: UIViewController) {
        self.viewControllerBehind?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func close(_ destinationViewController: UIViewController? = nil) {
        if let destinationViewController = destinationViewController {
            self.viewControllerBehind?.navigationController?.popToViewController(destinationViewController, animated: animated)
        } else {
            self.viewControllerBehind?.navigationController?.popViewController(animated: animated)
        }
    }
}
