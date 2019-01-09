//
//  SplashPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

final class SplashPresenter: AuthUseCaseOutput {
    
    private let view: SplashView
    
    init(view: SplashView) {
        self.view = view
    }
    
    func authSucceeded() {
        view.displayMain()
    }
    
    func authFailed() {
        view.displayRegister()
    }
}
