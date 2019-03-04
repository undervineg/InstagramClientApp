
//
//  UserSearchPResenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 20/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

protocol SearchView: ErrorPresentable {
    func displayAllUsers(_ users: [User])
}

final class UserSearchPresenter: SearchUseCaseOutput {
    private let view: SearchView
    
    init(view: SearchView) {
        self.view = view
    }
    
    func fetchAllUserSucceeded(_ users: [User]) {
        view.displayAllUsers(users)
    }
    
    func fetchAllUserFailed(_ error: Error) {
        view.displayError(error.localizedDescription)
    }
    
    func downloadProfileImageFailed(_ error: UserProfileUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
}

extension WeakRef: SearchView where T: SearchView {
    func displayAllUsers(_ users: [User]) {
        object?.displayAllUsers(users)
    }
}
