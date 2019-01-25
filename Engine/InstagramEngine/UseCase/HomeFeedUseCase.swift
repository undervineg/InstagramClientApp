//
//  HomeFeedUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 19/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol LoadPostClient {
    func fetchAllPosts(_ completion: @escaping (Result<Post, Error>) -> Void)
    func fetchCurrentUserPost(_ completion: @escaping (Result<Post, Error>) -> Void)
    func fetchCurrentUserPost(with order: Post.Order, _ completion: @escaping (Result<Post, Error>) -> Void)
    func fetchUserPost(of uid: String, with order: Post.Order, _ completion: @escaping (Result<Post, Error>) -> Void)
    func fetchUserPost(of uid: String, _ completion: @escaping (Result<Post, Error>) -> Void)
    func downloadPostImage(from url: URL, completion: @escaping (Result<Data, Error>) -> Void)
    func increaseLikes(of postId: String, completion: @escaping (Error?) -> Void)
}

public protocol LoadPostOutput {
    func loadPostSucceeded(_ post: Post)
    func loadPostFailed(_ error: Error)
    func downloadPostImageFailed(_ error: Error)
}

public protocol LikesOutput {
    func likesFailed(_ error: Error)
}

final public class HomeFeedUseCase: FeaturePostLoadable {
    public let postClient: LoadPostClient
    public let postOutput: LoadPostOutput
    let likesOutput: LikesOutput
    
    public init(postClient: LoadPostClient, output: LoadPostOutput&LikesOutput) {
        self.postClient = postClient
        self.postOutput = output
        self.likesOutput = output
    }
    
    public enum Error: Swift.Error {
        case userIDNotExist
        case postsNotExist
        case postImageNotFound
        case fetchFollowingListError
        case saveLikesError
        
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
            case .saveLikesError:
                return "좋아요 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
            }
        }
    }
    
    public func saveLikes(of postId: String, isIncrease: Bool) {
        isIncrease ?
            postClient.increaseLikes(of: postId, completion: handleSaveLikesResult) : nil
    }
    
    // MARK: Private Methods
    private func handleLoadedPost(_ result: Result<Post, HomeFeedUseCase.Error>) {
        switch result {
        case .success(let post):
            self.postOutput.loadPostSucceeded(post)
        case .failure(let error):
            postOutput.loadPostFailed(error)
        }
    }
    
    private func handleSaveLikesResult(_ error: Swift.Error?) {
        if error != nil {
            likesOutput.likesFailed(HomeFeedUseCase.Error.saveLikesError)
        }
    }
}
