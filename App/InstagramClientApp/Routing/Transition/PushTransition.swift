//
//  PushTransition.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class PushTransition: Transition {
    
    weak var viewController: UIViewController?
    
    private let animated: Bool
    var completion: (() -> Void)?
    
    init(animated: Bool = true) {
        self.animated = animated
    }
    
    func open(_ viewController: UIViewController) {
        self.viewController?.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func close(_ viewController: UIViewController) {
        self.viewController?.navigationController?.popViewController(animated: animated)
    }
    
    func close(to destVC: UIViewController) {
        self.viewController?.navigationController?.popToViewController(destVC, animated: animated)
    }
}
