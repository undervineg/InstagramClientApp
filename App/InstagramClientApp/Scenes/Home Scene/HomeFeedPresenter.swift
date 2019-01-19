//
//  HomeFeedPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 19/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

final class HomeFeedPresenter: LoadPostOutput {
    private let view: PostView
    
    init(view: PostView) {
        self.view = view
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
}

extension WeakRef: LoadPostOutput where T: LoadPostOutput {
    func loadPostSucceeded(_ post: Post) {
        object?.loadPostSucceeded(post)
    }
    
    func loadPostsFailed(_ error: HomeFeedUseCase.Error) {
        object?.loadPostsFailed(error)
    }
    
    func downloadPostImageFailed(_ error: HomeFeedUseCase.Error) {
        object?.downloadPostImageFailed(error)
    }
}
