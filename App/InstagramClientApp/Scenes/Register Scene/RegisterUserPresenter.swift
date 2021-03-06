//
//  RegisterUserPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

protocol RegisterUserView: ErrorPresentable {
    func displayMain()
}

final class RegisterUserPresenter: RegisterUserUseCaseOutput {
    
    private let view: RegisterUserView
    
    init(view: RegisterUserView) {
        self.view = view
    }
    
    func registerSucceeded() {
        view.displayMain()
    }
    
    func registerFailed(_ error: RegisterUserUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
    
}

extension WeakRef: RegisterUserView where T: RegisterUserView {
    func displayMain() {
        object?.displayMain()
    }
}
