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
    func onLogoutSucceeded()
    func toggleFollowButton(_ isFollowing: Bool)
}

protocol PostView: ErrorPresentable {
    func displayPost(_ post: Post)
}

final class UserProfilePresenter: UserProfileUseCaseOutput, LoadPostOutput {
    private let view: UserProfileView & PostView
    
    init(view: UserProfileView & PostView) {
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
    
    func loadPostsFailed(_ error: HomeFeedUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
    
    func downloadPostImageFailed(_ error: HomeFeedUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
    
    func followUserSucceeeded() {
        view.toggleFollowButton(true)
    }
    
    func followUserFailed(_ error: UserProfileUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
    
    func checkIsFollowSucceeded(_ isFollowing: Bool) {
        view.toggleFollowButton(isFollowing)
    }
    
    func checkIsFollowFailed(_ error: Error) {
        view.displayError(error.localizedDescription)
    }
}

extension WeakRef: UserProfileView where T: UserProfileView {
    func toggleFollowButton(_ isFollowing: Bool) {
        object?.toggleFollowButton(isFollowing)
    }
    
    func displayUserInfo(_ user: User) {
        object?.displayUserInfo(user)
    }
    
    func onLogoutSucceeded() {
        object?.onLogoutSucceeded()
    }
}

extension WeakRef: PostView where T: PostView {
    func displayPost(_ post: Post) {
        object?.displayPost(post)
    }
}
