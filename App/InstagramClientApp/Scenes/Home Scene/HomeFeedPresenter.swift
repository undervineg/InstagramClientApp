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
    func displayPostObjects(_ posts: [PostObject], hasMoreToLoad: Bool)
    func displayReloadedPosts(_ posts: [PostObject], hasMoreToLoad: Bool)
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
    
    func loadPostSucceeded(_ post: PostObject?) {
        guard let post = post else { return }
        view.displayPostObjects([post], hasMoreToLoad: false)
    }
    
    func loadPostsSucceeded(_ posts: [PostObject]) {
        view.displayPostObjects(posts, hasMoreToLoad: false)
    }
    
    func loadPaginatedPostSucceeded(_ posts: [PostObject], hasMoreToLoad: Bool, isReloading: Bool) {
        if isReloading {
            view.displayReloadedPosts(posts, hasMoreToLoad: hasMoreToLoad)
        } else {
            view.displayPostObjects(posts, hasMoreToLoad: hasMoreToLoad)
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
    func displayReloadedPosts(_ posts: [PostObject], hasMoreToLoad: Bool) {
        object?.displayReloadedPosts(posts, hasMoreToLoad: hasMoreToLoad)
    }
    
    func displayPostObjects(_ posts: [PostObject], hasMoreToLoad: Bool) {
        object?.displayPostObjects(posts, hasMoreToLoad: hasMoreToLoad)
    }
    
    func displayPostsCount(_ count: Int) {
        object?.displayPostsCount(count)
    }
}

extension WeakRef: LikesView where T: LikesView {
    func displayLikes(_ hasLiked: Bool, at index: Int) {
        object?.displayLikes(hasLiked, at: index)
    }
}
