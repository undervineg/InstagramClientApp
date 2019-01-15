//
//  Transition.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

enum TransitionType {
    case modal
    case push
    
    var object: Transition {
        switch self {
        case .modal: return ModalTransition()
        case .push: return PushTransition()
        }
    }
}

protocol Transition: class {
    var viewControllerBehind: UIViewController? { get set }
    
    func open(_ viewController: UIViewController)
    func close()
    func close(to destVC: UIViewController)
}
