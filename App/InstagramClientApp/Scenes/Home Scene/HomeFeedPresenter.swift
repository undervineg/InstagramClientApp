//
//  HomeFeedPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 19/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

protocol PostView: ErrorPresentable {
    func displayPostsCount(_ count: Int)
    func displayPosts(_ posts: [Post?], hasMoreToLoad: Bool)
    func displayReloadedPosts(_ posts: [Post], hasMoreToLoad: Bool)
}

protocol LikesView: ErrorPresentable {
    func displayLikes(_ hasLiked: Bool, at index: Int)
}

final class HomeFeedPresenter: LoadPostOutput, LikesOutput {
    private let view: PostView & LikesView
    
    init(view: PostView & LikesView) {
        self.view = view
    }
    
    func loadPostsCountSucceeded(_ count: Int) {
        view.displayPostsCount(count)
    }
    
    func loadPostSucceeded(_ post: Post?) {
        view.displayPosts([post], hasMoreToLoad: false)
    }
    
    func loadPaginatedPostSucceeded(_ posts: [Post], hasMoreToLoad: Bool, isReloading: Bool) {
        if isReloading {
            view.displayReloadedPosts(posts, hasMoreToLoad: hasMoreToLoad)
        } else {
            view.displayPosts(posts, hasMoreToLoad: hasMoreToLoad)
        }
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
    func displayPosts(_ posts: [Post?], hasMoreToLoad: Bool) {
        object?.displayPosts(posts, hasMoreToLoad: hasMoreToLoad)
    }
    
    func displayPostsCount(_ count: Int) {
        object?.displayPostsCount(count)
    }
    
    func displayReloadedPosts(_ posts: [Post], hasMoreToLoad: Bool) {
        object?.displayReloadedPosts(posts, hasMoreToLoad: hasMoreToLoad)
    }
}

extension WeakRef: LikesView where T: LikesView {
    func displayLikes(_ hasLiked: Bool, at index: Int) {
        object?.displayLikes(hasLiked, at: index)
    }
}
