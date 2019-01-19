//
//  HomeFeedUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 19/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol Cacheable {
    func cache(_ data: Data, with key: String)
    func getCachedData(key: String) -> Data?
}

public protocol LoadPostClient {
    func fetchPost(_ completion: @escaping (Result<Post, HomeFeedUseCase.Error>) -> Void)
    func fetchPost(with order: HomeFeedUseCase.Order, _ completion: @escaping (Result<Post, HomeFeedUseCase.Error>) -> Void)
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
    
    private let client: LoadPostClient
    private let output: LoadPostOutput
    private let cacheManager: Cacheable
    
    public init(client: LoadPostClient, output: LoadPostOutput, cacheManager: Cacheable) {
        self.client = client
        self.output = output
        self.cacheManager = cacheManager
    }
    
    public enum Order {
        case creationDate(Sort)
        case caption(Sort)
    }
    
    public enum Error: Swift.Error {
        case userIDNotExist
        case postsNotExist
        case postImageNotFound
        
        public var localizedDescription: String {
            switch self {
            case .userIDNotExist:
                return "일부 사용자 계정을 찾을 수 없습니다."
            case .postsNotExist:
                return "사용자의 게시물이 존재하지 않습니다."
            case .postImageNotFound:
                return "일부 게시글의 이미지를 불러올 수 없습니다."
            }
        }
    }
    
    public func loadAllPosts() {
        client.fetchPost { [weak self] (result) in
            switch result {
            case .success(let post):
                self?.output.loadPostSucceeded(post)
            case .failure(let error):
                self?.output.loadPostsFailed(error)
            }
        }
    }
    
    public func loadPosts(orderBy order: Order) {
        client.fetchPost(with: order) { [weak self] (result) in
            switch result {
            case .success(let post):
                self?.output.loadPostSucceeded(post)
            case .failure(let error):
                self?.output.loadPostsFailed(error)
            }
        }
    }
    
    public func downloadPostImage(from url: URL, completion: @escaping (Data) -> Void) {
        if let cachedData = cacheManager.getCachedData(key: url.absoluteString) {
            completion(cachedData)
            return
        }
        client.downloadPostImage(from: url) { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.cacheManager.cache(data, with: url.absoluteString)
                completion(data)
            case .failure(let error):
                self?.output.downloadPostImageFailed(error)
            }
        }
    }
}