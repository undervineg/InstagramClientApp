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
    func displayPost(_ post: Post)
    func onLogoutSucceeded()
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
        view.displayError(error.localizedDescription)
    }
    
    func downloadProfileImageFailed(_ error: UserProfileUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
    
    func logoutSucceeded() {
        view.onLogoutSucceeded()
    }
    
    func logoutFailed(_ error: UserProfileUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
    
    func loadPostSucceeded(_ post: Post) {
        view.displayPost(post)
    }
    
    func loadPostsFailed(_ error: UserProfileUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
    
    func downloadPostImageFailed(_ error: UserProfileUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
}

extension WeakRef: UserProfileView where T: UserProfileView {
    func displayUserInfo(_ user: User) {
        object?.displayUserInfo(user)
    }
    
    func displayPost(_ post: Post) {
        object?.displayPost(post)
    }
    
    func onLogoutSucceeded() {
        object?.onLogoutSucceeded()
    }
}
