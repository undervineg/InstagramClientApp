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
}

extension ErrorPresentable where Self: UIViewController {
    func displayError(_ errorMessage: String) {
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension WeakRef: ErrorPresentable where T: ErrorPresentable {
    func displayError(_ errorMessage: String) {
        object?.displayError(errorMessage)
    }
}
