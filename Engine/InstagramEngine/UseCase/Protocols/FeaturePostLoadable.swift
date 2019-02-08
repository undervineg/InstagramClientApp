//
//  FeaturePostLoadable.swift
//  InstagramEngine
//
//  Created by 심승민 on 26/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol FeaturePostLoadable: class {
    var postClient: LoadPostClient { get }
    var postOutput: LoadPostOutput { get }
    
    func loadAllPosts()
    func loadPosts(of uid: String?, orderBy order: Post.Order)
    func loadPaginatePosts(of uid: String?, from postId: Any?, limit: Int, orderBy order: Post.Order, isReloading: Bool)
    func downloadPostImage(from url: URL, completion: @escaping (Data) -> Void)
}

public protocol LoadPostOutput {
    func loadPostSucceeded(_ post: Post)
    func loadPaginatedPostSucceeded(_ posts: [Post], hasMoreToLoad: Bool, isReloading: Bool)
    func loadPostFailed(_ error: Error)
    func downloadPostImageFailed(_ error: Error)
}

extension FeaturePostLoadable {
    public func loadAllPosts() {
        postClient.fetchAllPosts(handleLoadedPost)
    }
    
    public func loadPosts(of uid: String?, orderBy order: Post.Order) {
        if let uid = uid {
            postClient.fetchUserPostWithOrder(of: uid, order, handleLoadedPost)
        } else {
            postClient.fetchCurrentUserPostWithOrder(order, handleLoadedPost)
        }
    }
    
    public func loadPaginatePosts(of uid: String?, from postId: Any?, limit: Int, orderBy order: Post.Order, isReloading: Bool) {
        if let uid = uid {
            postClient.fetchUserPostWithPagination(of: uid, from: postId, to: limit, with: order) {
                self.handlePaginateLoadedPost($0, isReloading: isReloading)
            }
        } else {
            postClient.fetchCurrentUserPostWithPagination(startFrom: postId, to: limit, with: order) {
                self.handlePaginateLoadedPost($0, isReloading: isReloading)
            }
        }
    }
    
    public func downloadPostImage(from url: URL, completion: @escaping (Data) -> Void) {
        postClient.downloadPostImage(from: url) { [weak self] (result) in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                self?.postOutput.downloadPostImageFailed(error)
            }
        }
    }
    
    // MARK: Private Methods
    private func handleLoadedPost(_ result: Result<Post, Error>) {
        switch result {
        case .success(let post):
            postOutput.loadPostSucceeded(post)
        case .failure(let error):
            postOutput.loadPostFailed(error)
        }
    }
    
    private func handlePaginateLoadedPost(_ result: Result<([Post], Bool), Error>, isReloading: Bool) {
        switch result {
        case .success(let (posts, isPagingFinished)):
            postOutput.loadPaginatedPostSucceeded(posts, hasMoreToLoad: !isPagingFinished, isReloading: isReloading)
        case .failure(let error):
            postOutput.loadPostFailed(error)
        }
    }
}
