//
//  FeaturePostLoadable.swift
//  InstagramEngine
//
//  Created by 심승민 on 26/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol LoadPostClient {
    func fetchPost(of uid: String?, at postId: String, _ completion: @escaping (Result<PostObject?, Error>) -> Void)
    func fetchPost(of uid: String?, _ completion: @escaping (Result<PostObject?, Error>) -> Void)
    func fetchAllPosts(of uid: String?, _ completion: @escaping (Result<PostObject?, Error>) -> Void)
    func fetchFollowerPosts(of uid: String?, _ completion: @escaping (Result<PostObject?, Error>) -> Void)
    func fetchPostWithPagination(of uid: String?, from postId: Any?, to limit: Int, with order: Post.Order, completion: @escaping (Result<([PostObject], Bool), Error>) -> Void)
    func fetchPostsCount(of uid: String?, _ completion: @escaping (Int) -> Void)
    
    func fetchUserLikes(_ postId: String, of uidWhoPosted: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func changeLikes(_ postId: String, of uidWhoPosted: String, to likesState: Bool, completion: @escaping (Error?) -> Void)
}

public protocol FeaturePostLoadable: class {
    var postClient: LoadPostClient { get }
    var postOutput: LoadPostOutput { get }
    
    func getPostsCount(of uid: String?)
    func loadAllPosts(of uid: String?)
    func loadFollowingPosts(of uid: String?)
    func loadPaginatePosts(of uid: String?, from postId: Any?, limit: Int, orderBy order: Post.Order, isReloading: Bool)
}

public protocol LoadPostOutput {
    func loadPostsCountSucceeded(_ count: Int)
    func loadPostSucceeded(_ post: PostObject?)
    func loadPaginatedPostSucceeded(_ posts: [PostObject], hasMoreToLoad: Bool, isReloading: Bool)
    func loadPostFailed(_ error: Error)
}

extension FeaturePostLoadable {
    public func getPostsCount(of uid: String?) {
        postClient.fetchPostsCount(of: uid) { [weak self] in
            self?.postOutput.loadPostsCountSucceeded($0)
        }
    }
    
    public func loadAllPosts(of uid: String?) {
        postClient.fetchAllPosts(of: uid) { [weak self] in
            switch $0 {
            case .success(let postObj):
                self?.postOutput.loadPostSucceeded(postObj)
            case .failure(let error):
                self?.postOutput.loadPostFailed(error)
            }
        }
    }
    
    public func loadFollowingPosts(of uid: String?) {
        postClient.fetchFollowerPosts(of: uid) { [weak self] in
            switch $0 {
            case .success(let postObj):
                self?.postOutput.loadPostSucceeded(postObj)
            case .failure(let error):
                self?.postOutput.loadPostFailed(error)
            }
        }
    }
    
    public func loadPaginatePosts(of uid: String?, from postId: Any?, limit: Int, orderBy order: Post.Order, isReloading: Bool) {
        postClient.fetchPostWithPagination(of: uid, from: postId, to: limit, with: order) {
            self.handlePaginateLoadedPost($0, isReloading: isReloading)
        }
    }
    
    // MARK: Private Methods
    private func handlePaginateLoadedPost(_ result: Result<([PostObject], Bool), Error>, isReloading: Bool) {
        switch result {
        case .success(let (posts, isPagingFinished)):
            postOutput.loadPaginatedPostSucceeded(posts, hasMoreToLoad: !isPagingFinished, isReloading: isReloading)
        case .failure(let error):
            postOutput.loadPostFailed(error)
        }
    }
}
