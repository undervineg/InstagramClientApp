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
    func loadPostFailed(_ error: HomeFeedUseCase.Error)
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
    
    private let serialQueue: DispatchQueue
    
    public init(postClient: LoadPostClient, profileClient: UserProfileClient, output: LoadPostOutput) {
        self.postClient = postClient
        self.profileClient = profileClient
        self.output = output
        self.serialQueue = DispatchQueue(label: "LoadPostsSerial", qos: .utility)
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
        profileClient.fetchFollowingListOfCurrentUser { [unowned self] (result) in
            switch result {
            case .success(let followingUsers):
                self.postClient.fetchCurrentUserPost(self.handleLoadedPost)
                followingUsers.forEach { (uid) in
                    self.postClient.fetchUserPost(of: uid, self.handleLoadedPost)
                }
            case .failure:
                self.output.loadPostFailed(.fetchFollowingListError)
            }
        }
    }
    
    public func loadPosts(of uid: String?, orderBy order: Post.Order) {
        if let uid = uid {
            postClient.fetchUserPost(of: uid, handleLoadedPost)
        } else {
            postClient.fetchCurrentUserPost(with: order, handleLoadedPost)
        }
    }
    
    private func handleLoadedPost(_ result: Result<Post, HomeFeedUseCase.Error>) {
        switch result {
        case .success(let post):
            serialQueue.async {
                self.output.loadPostSucceeded(post)
            }
        case .failure(let error):
            output.loadPostFailed(error)
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
