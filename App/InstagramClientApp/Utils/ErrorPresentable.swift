//
//  ErrorPresentable.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol ErrorPresentable {
    func displayError(_ errorMessage: String)
    // Below are not delegate methods
    func displayError(_ errorMessage: String, _ okCompletion: ((UIAlertAction) -> Void)?)
    func displayError(_ errorMessage: String, with actions: [UIAlertAction], _ okCompletion: ((UIAlertAction) -> Void)?)
}

extension ErrorPresentable where Self: UIViewController {
    func displayError(_ errorMessage: String) {
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func displayError(_ errorMessage: String, _ okCompletion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: okCompletion))
        present(alert, animated: true, completion: nil)
    }
    
    func displayError(_ errorMessage: String, with actions: [UIAlertAction], _ okCompletion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: okCompletion))
        present(alert, animated: true, completion: nil)
    }
}

extension WeakRef: ErrorPresentable where T: ErrorPresentable {
    func displayError(_ errorMessage: String, _ okCompletion: ((UIAlertAction) -> Void)?) {
        object?.displayError(errorMessage, okCompletion)
    }
    
    func displayError(_ errorMessage: String, with actions: [UIAlertAction], _ okCompletion: ((UIAlertAction) -> Void)?) {
        object?.displayError(errorMessage, with: actions, okCompletion)
    }
    
    func displayError(_ errorMessage: String) {
        object?.displayError(errorMessage)
    }
}
