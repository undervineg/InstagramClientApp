//
//  HomeFeedPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 19/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

protocol PostView: ErrorPresentable {
    func displayPost(_ post: Post)
}

final class HomeFeedPresenter: LoadPostOutput {
    private let view: PostView
    
    init(view: PostView) {
        self.view = view
    }
    
    func loadPostSucceeded(_ post: Post) {
        view.displayPost(post)
    }
    
    func loadPostFailed(_ error: HomeFeedUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
    
    func downloadPostImageFailed(_ error: HomeFeedUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
}

extension WeakRef: PostView where T: PostView {
    func displayPost(_ post: Post) {
        object?.displayPost(post)
    }
}
