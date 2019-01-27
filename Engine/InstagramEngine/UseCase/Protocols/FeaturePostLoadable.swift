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
    func downloadPostImage(from url: URL, completion: @escaping (Data) -> Void)
}

extension FeaturePostLoadable {
    public func loadAllPosts() {
        postClient.fetchAllPosts(handleLoadedPost)
    }
    
    public func loadPosts(of uid: String?, orderBy order: Post.Order) {
        if let uid = uid {
            postClient.fetchUserPost(of: uid, handleLoadedPost)
        } else {
            postClient.fetchCurrentUserPost(with: order, handleLoadedPost)
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
}
