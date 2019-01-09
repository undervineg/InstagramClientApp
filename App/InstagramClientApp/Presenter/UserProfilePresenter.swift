//
//  UserProfilePresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

final class UserProfilePresenter: UserProfileUseCaseOutput {
    
    private let view: UserProfileView
    
    init(view: UserProfileView) {
        self.view = view
    }
    
    func loadUserSucceeded(_ user: UserEntity) {
        view.displayTitle(user.username)
    }
    
    func loadUserFailed(_ error: UserProfileUseCase.Error) {
        var errorMessage = ""
        switch error {
        case .currentUserIDNotExist:
            errorMessage = "사용자 계정이 없습니다."
        case .currentUserNotExist:
            errorMessage = "사용자 정보가 없습니다."
        }
        view.displayError(errorMessage)
    }
}

extension WeakRef: UserProfileView where T: UserProfileView {
    func displayTitle(_ title: String) {
        object?.displayTitle(title)
    }
    
    func displayError(_ errorMessage: String) {
        object?.displayError(errorMessage)
    }
}
