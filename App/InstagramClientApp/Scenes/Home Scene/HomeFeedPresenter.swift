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
    func displayLikes(_ isLike: Bool)
}

final class HomeFeedPresenter: LoadPostOutput {
    private let view: PostView
    
    init(view: PostView) {
        self.view = view
    }
    
    func loadPostSucceeded(_ post: Post) {
        view.displayPost(post)
    }
    
    func loadPostFailed(_ error: Error) {
        view.displayError(error.localizedDescription)
    }
    
    func downloadPostImageFailed(_ error: Error) {
        view.displayError(error.localizedDescription)
    }
    
    func loadLikesSucceeded(_ isLike: Bool) {
        view.displayLikes(isLike)
    }
    
    func loadLikesFailed(_ error: Error) {
        view.displayError(error.localizedDescription)
    }
    
    func increaseLikesSucceeded() {
        
    }
    
    func decreaseLikesSucceeded() {
        
    }
    
    func saveLikesFailed(_ error: Error) {
        view.displayError(error.localizedDescription)
    }
}

extension WeakRef: PostView where T: PostView {
    func displayLikes(_ isLike: Bool) {
        object?.displayLikes(isLike)
    }
    
    func displayPost(_ post: Post) {
        object?.displayPost(post)
    }
}
