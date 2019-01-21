//
//  HomeFeedUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 19/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol LoadPostClient {
    func fetchCurrentUserPost(_ completion: @escaping (Result<Post, HomeFeedUseCase.Error>) -> Void)
    func fetchCurrentUserPost(with order: Post.Order, _ completion: @escaping (Result<Post, HomeFeedUseCase.Error>) -> Void)
    func fetchUserPost(of uid: String, with order: Post.Order, _ completion: @escaping (Result<Post, HomeFeedUseCase.Error>) -> Void)
    func fetchUserPost(of uid: String, _ completion: @escaping (Result<Post, HomeFeedUseCase.Error>) -> Void)
    func downloadPostImage(from url: URL, completion: @escaping (Result<Data, HomeFeedUseCase.Error>) -> Void)
}

public protocol LoadPostOutput {
    func loadPostSucceeded(_ post: Post)
    func loadPostsFailed(_ error: HomeFeedUseCase.Error)
    func downloadPostImageFailed(_ error: HomeFeedUseCase.Error)
}

public enum Sort {
    case ascending
    case descending
}

final public class HomeFeedUseCase {
    
    private let postClient: LoadPostClient
    private let profileClient: UserProfileClient
    private let output: LoadPostOutput
    
    public init(postClient: LoadPostClient, profileClient: UserProfileClient, output: LoadPostOutput) {
        self.postClient = postClient
        self.profileClient = profileClient
        self.output = output
    }
    
    public enum Error: Swift.Error {
        case userIDNotExist
        case postsNotExist
        case postImageNotFound
        case fetchFollowingListError
        
        public var localizedDescription: String {
            switch self {
            case .userIDNotExist:
                return "일부 사용자 계정을 찾을 수 없습니다."
            case .postsNotExist:
                return "사용자의 게시물이 존재하지 않습니다."
            case .postImageNotFound:
                return "일부 게시글의 이미지를 불러올 수 없습니다."
            case .fetchFollowingListError:
                return "사용자의 팔로우 리스트를 불러오는 데 문제가 발생했습니다."
            }
        }
    }
    
    public func loadAllPosts() {
        profileClient.fetchFollowingListOfCurrentUser { [weak self] (result) in
            switch result {
            case .success(let followingUsers):
                self?.postClient.fetchCurrentUserPost { self?.handleLoadedPostResult($0) }
                followingUsers.forEach { (uid) in
                    self?.postClient.fetchUserPost(of: uid) { self?.handleLoadedPostResult($0) }
                }
            case .failure:
                self?.output.loadPostsFailed(.fetchFollowingListError)
            }
        }
    }
    
    private func handleLoadedPostResult(_ result: Result<Post, HomeFeedUseCase.Error>) {
        switch result {
        case .success(let post):
            output.loadPostSucceeded(post)
        case .failure(let error):
            output.loadPostsFailed(error)
        }
    }
    
    public func loadPosts(of uid: String?, orderBy order: Post.Order) {
        if let uid = uid {
            postClient.fetchUserPost(of: uid, handleLoadPostsResult)
        } else {
            postClient.fetchCurrentUserPost(with: order, handleLoadPostsResult)
        }
    }
    
    private func handleLoadPostsResult(_ result: Result<Post, HomeFeedUseCase.Error>) {
        switch result {
        case .success(let post):
            output.loadPostSucceeded(post)
        case .failure(let error):
            output.loadPostsFailed(error)
        }
    }
    
    public func downloadPostImage(from url: URL, completion: @escaping (Data) -> Void) {
        postClient.downloadPostImage(from: url) { [weak self] (result) in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                self?.output.downloadPostImageFailed(error)
            }
        }
    }
}
