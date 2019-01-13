//
//  LoginPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 13/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

protocol LoginView {
    func displayMain()
    func displayError(_ message: String)
}

class LoginPresenter: LoginUseCaseOutput {
    
    private let view: LoginView
    
    init(view: LoginView) {
        self.view = view
    }
    
    func loginSucceeded() {
        view.displayMain()
    }
    
    func loginFailed(_ error: LoginUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
}

extension WeakRef: LoginView where T: LoginView {
    func displayMain() {
        object?.displayMain()
    }
    
    func displayError(_ message: String) {
        object?.displayError(message)
    }
}
