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

protocol LikesView: ErrorPresentable {
    func displayLikes(_ hasLiked: Bool, at index: Int)
}

final class HomeFeedPresenter: LoadPostOutput, LikesOutput {
    private let view: PostView & LikesView
    
    init(view: PostView & LikesView) {
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
    
    func changeLikesSucceeded(to newState: Bool, at index: Int) {
        view.displayLikes(newState, at: index)
    }
    
    func saveLikesFailed(_ error: Error) {
        view.displayError(error.localizedDescription)
    }
}

extension WeakRef: PostView where T: PostView {
    func displayPost(_ post: Post) {
        object?.displayPost(post)
    }
}

extension WeakRef: LikesView where T: LikesView {
    func displayLikes(_ hasLiked: Bool, at index: Int) {
        object?.displayLikes(hasLiked, at: index)
    }
}
