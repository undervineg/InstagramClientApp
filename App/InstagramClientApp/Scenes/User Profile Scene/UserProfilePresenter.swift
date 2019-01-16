//
//  UserProfilePresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine
import Foundation

protocol UserProfileView: ErrorPresentable {
    func displayUserInfo(_ user: User)
    func displayProfileImage(_ imageData: Data)
    func close()
}

final class UserProfilePresenter: UserProfileUseCaseOutput {
    
    private let view: UserProfileView
    
    init(view: UserProfileView) {
        self.view = view
    }
    
    func loadUserSucceeded(_ user: User) {
        view.displayUserInfo(user)
    }
    
    func loadUserFailed(_ error: UserProfileUseCase.Error) {
        var errorMessage = ""
        switch error {
        case .currentUserIDNotExist:
            errorMessage = "사용자 계정이 없습니다."
        case .currentUserNotExist:
            errorMessage = "사용자 정보가 없습니다."
        case .profileImageNotExist:
            errorMessage = "프로필 이미지를 불러올 수 없습니다."
        case .logoutError:
            errorMessage = "로그아웃 도중 문제가 발생했습니다."
        }
        view.displayError(errorMessage)
    }
    
    func downloadProfileImageSucceeded(_ imageData: Data) {
        view.displayProfileImage(imageData)
    }
    
    func downloadProfileImageFailed(_ error: UserProfileUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
    
    func logoutSucceeded() {
        view.close()
    }
    
    func logoutFailed(_ error: UserProfileUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
}

extension WeakRef: UserProfileView where T: UserProfileView {
    func displayUserInfo(_ user: User) {
        object?.displayUserInfo(user)
    }
    
    func displayProfileImage(_ imageData: Data) {
        object?.displayProfileImage(imageData)
    }
    
    func close() {
        object?.close()
    }
}
