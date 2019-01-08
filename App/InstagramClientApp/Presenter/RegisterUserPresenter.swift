//
//  RegisterUserPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

class RegisterUserPresenter: RegisterUserUseCaseOutput {
    
    private let view: RegisterUserView
    
    init(view: RegisterUserView) {
        self.view = view
    }
    
    func registerSucceeded() {
        // move to MainTabBarViewController
    }
    
    func registerFailed(_ error: RegisterUserUseCase.Error) {
        view.display(error.localizedDescription)
    }
    
}

protocol RegisterUserView {
    func display(_ errorMessage: String)
}

extension WeakRef: RegisterUserView where T: RegisterUserView {
    func display(_ errorMessage: String) {
        object?.display(errorMessage)
    }
}
