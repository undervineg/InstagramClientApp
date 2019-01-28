//
//  PostService.swift
//  InstagramClientApp
//
//  Created by 심승민 on 19/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import InstagramEngine

final class PostService: LoadPostClient {
    private let auth: FirebaseAuthWrapper.Type
    private let database: FirebaseDatabaseWrapper.Type
    private let networking: APIClient
    private let profileService: UserProfileService
    
    init(firebaseAuth: FirebaseAuthWrapper.Type,
         firebaseDatabase: FirebaseDatabaseWrapper.Type,
         networking: APIClient,
         profileService: UserProfileService) {
        self.auth = firebaseAuth
        self.database = firebaseDatabase
        self.networking = networking
        self.profileService = profileService
    }
    
    func fetchAllPosts(_ completion: @escaping (Result<Post, Error>) -> Void) {
        fetchCurrentUserPost { (result) in
            switch result {
            case .success(let post): completion(.success(post))
            case .failure(let error): completion(.failure(error))
            }
        }
        profileService.fetchFollowingListOfCurrentUser { [unowned self] (result) in
            switch result {
            case .success(let followingUsers):
                followingUsers.forEach { (uid) in
                    self.fetchUserPost(of: uid) { result in
                        switch result {
                        case .success(let post): completion(.success(post))
                        case .failure(let error): completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchCurrentUserPost(_ completion: @escaping (Result<Post, Error>) -> Void) {
        guard let currentUserId = auth.currentUserId else {
            completion(.failure(HomeFeedUseCase.Error.userIDNotExist))
            return
        }
        fetchUserPost(of: currentUserId, completion)
    }
    
    func fetchCurrentUserPostWithOrder(_ order: Post.Order, _ completion: @escaping (Result<Post, Error>) -> Void) {
        guard let currentUserId = auth.currentUserId else {
            completion(.failure(HomeFeedUseCase.Error.userIDNotExist))
            return
        }
        fetchUserPostWithOrder(of: currentUserId, order, completion)
    }
    
    func fetchCurrentUserPostWithPagination(startFrom postId: String?, to limit: Int, completion: @escaping (Result<([Post], Bool), Error>) -> Void) {
        guard let currentUserId = auth.currentUserId else {
            completion(.failure(HomeFeedUseCase.Error.userIDNotExist))
            return
        }
        fetchUserPostWithPagination(of: currentUserId, from: postId, to: limit, completion: completion)
    }
    
    func fetchUserPost(of uid: String, _ completion: @escaping (Result<Post, Error>) -> Void) {
        let refs: [Reference] = [Reference.directory(Keys.Database.postsDir), .directory(uid)]
        
        database.fetchAll(under: refs) { [weak self] (result: Result<[String: Any], Error>) in
            switch result {
            case .success(let values):
                values.forEach({ (key, value) in
                    guard let value = value as? [String: Any] else { return }
                    self?.generatePost(of: uid, postId: key, value: value, completion: completion)
                })
            default: return
            }
        }
    }
    
    func fetchUserPostWithOrder(of uid: String, _ order: Post.Order, _ completion: @escaping (Result<Post, Error>) -> Void) {
        let refs: [Reference] = [Reference.directory(Keys.Database.postsDir), .directory(uid)]
        
        database.fetch(under: refs, orderBy: order) { [weak self] (result: Result<(String, [String: Any]), Error>) in
            switch result {
            case .success(let (postId, postValues)):
                self?.generatePost(of: uid, postId: postId, value: postValues, completion: completion)
            default: return
            }
        }
    }
    
    func fetchUserPostWithPagination(of uid: String, from postId: String?, to limit: Int, completion: @escaping (Result<([Post], Bool), Error>) -> Void) {
        let refs: [Reference] = [Reference.directory(Keys.Database.postsDir), .directory(uid)]
        
        database.fetch(under: refs, from: postId, to: limit) { (result: Result<([String: [String: Any]], Bool), Error>) in
            switch result {
            case .success(let (rawPostsChunk, isPagingFinished)):
                var loadedPostsChunk: [Post] = []
                rawPostsChunk.forEach { (arg) in
                    let (postId, postValues) = arg
                    self.generatePost(of: uid, postId: postId, value: postValues) {
                        switch $0 {
                        case .success(let post):
                            loadedPostsChunk.append(post)
                            if loadedPostsChunk.count == rawPostsChunk.count {
                                completion(.success((loadedPostsChunk, isPagingFinished)))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
                
            default: return
            }
        }
    }
    
    func downloadPostImage(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        networking.get(from: url) { (result) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                completion(.failure(HomeFeedUseCase.Error.postImageNotFound))
            }
        }
    }
    
    func changeLikes(of postId: String, to userNewlyLikes: Bool, completion: @escaping (Error?) -> Void) {
        guard let currentUid = auth.currentUserId else { return }
        let refs: [Reference] = [Reference.directory("likes"), .directory(postId)]
        let values = [currentUid: userNewlyLikes ? 1 : 0]
        
        database.update(values, under: refs, completion: completion)
    }

    func fetchUserLikes(of postId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUid = auth.currentUserId else { return }
        let refs: [Reference] = [.directory(Keys.Database.likesDir), .directory(postId), .directory(currentUid)]
        
        database.fetchAll(under: refs) { (result: Result<Int, Error>) in
            switch result {
            case .success(let count):
                (count == 1) ? completion(.success(true)) : completion(.success(false))
            case .failure(let error):
                if error._code == 1001 {    // if it's nil, the user has no likes to this post
                    completion(.success(false))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    // MARK: Private Methods
    private func generatePost(of uid: String, postId: String, value: [String: Any], completion: @escaping (Result<Post, Error>) -> Void) {
        profileService.loadUserInfo(of: uid) { [weak self] (result) in
            switch result {
            case .success(let userInfo):
                self?.fetchUserLikes(of: postId) { (result) in
                    switch result {
                    case .success(let hasLiked):
                        let caption = value[Keys.Database.Post.caption] as? String ?? ""
                        let imageUrl = value[Keys.Database.Post.image] as? String ?? ""
                        let imageWidth = value[Keys.Database.Post.imageWidth] as? Float ?? 0.0
                        let imageHeight = value[Keys.Database.Post.imageHeight] as? Float ?? 0.0
                        let creationDate = value[Keys.Database.Post.creationDate] as? Double ?? 0.0
                        
                        let post = Post(postId, userInfo, caption, imageUrl, imageWidth, imageHeight, creationDate, hasLiked)
                        
                        completion(.success(post))
                    case .failure:
                        completion(.failure(HomeFeedUseCase.Error.loadLikesError))
                    }
                }
            case .failure:
                completion(.failure(HomeFeedUseCase.Error.userIDNotExist))
            }
        }
    }
}

extension Post.Order: HasKey, Sortable {
    var sortBy: Sort {
        switch self {
        case .creationDate(let sort): return sort
        case .caption(let sort): return sort
        }
    }
    
    var key: String {
        switch self {
        case .creationDate: return Keys.Database.Post.creationDate
        case .caption: return Keys.Database.Post.caption
        }
    }
}
