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
    
    private let serialQueue = DispatchQueue(label: "serialQueue.PostService")
    
    init(firebaseAuth: FirebaseAuthWrapper.Type,
         firebaseDatabase: FirebaseDatabaseWrapper.Type,
         networking: APIClient,
         profileService: UserProfileService) {
        self.auth = firebaseAuth
        self.database = firebaseDatabase
        self.networking = networking
        self.profileService = profileService
    }
    
    func fetchAllPosts(of uid: String?, _ completion: @escaping (Result<Post?, Error>) -> Void) {
        self.fetchPost(of: uid) { result in
            switch result {
            case .success(let post):
//                self.serialQueue.async {
                    completion(.success(post))
//                }
            case .failure(let error): completion(.failure(error))
            }
        }
        
        profileService.fetchFollowingList(of: uid) { [unowned self] (result) in
            switch result {
            case .success(let followingUsers):
                followingUsers.forEach { (followingUser) in
                    self.fetchPost(of: followingUser) { result in
                        switch result {
                        case .success(let post):
//                            self.serialQueue.async {
                                completion(.success(post))
//                            }
                        case .failure(let error): completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchPostsCount(of uid: String?, _ completion: @escaping (Int) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.postsDir), .directory(userId), .directory(Keys.Database.count)]
        
        database.fetchAll(under: refs) { (result: Result<Int?, Error>) in
            switch result {
            case .success(let count): completion(count ?? 0)
            default: return
            }
        }
    }
    
    func fetchPostWithPagination(of uid: String?, from postId: Any?, to limit: Int, with order: Post.Order, completion: @escaping (Result<([Post], Bool), Error>) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.postsDir), .directory(userId), .directory(Keys.Database.contents)]

        var posts: [Post] = []
        database.fetch(under: refs, from: postId, to: limit, orderBy: order) { (result: Result<([(String, [String: Any])], Bool), Error>) in
            switch result {
            case .success(let (rawValues, isPagingFinished)):
                self.serialQueue.async {
                    rawValues.forEach { (key, values) in
                        let semaphore = DispatchSemaphore(value: 0)
                        self.generatePost(of: userId, postId: key, value: values) {
                            switch $0 {
                            case .success(let post):
                                posts.append(post)
                                semaphore.signal()
                                if posts.count == rawValues.count {
                                    completion(.success((posts, isPagingFinished)))
                                }
                            case .failure(let error): completion(.failure(error))
                            }
                        }
                        semaphore.wait()
                    }
                }
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func downloadPostImage(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        networking.get(from: url) { (result) in
            switch result {
            case .success(let data):
                if let data = data {
                    completion(.success(data))
                }
            case .failure:
                completion(.failure(HomeFeedUseCase.Error.postImageNotFound))
            }
        }
    }
    
    func changeLikes(of postId: String, to userNewlyLikes: Bool, completion: @escaping (Error?) -> Void) {
        guard let currentUid = auth.currentUserId else { return }
        let refs: [Reference] = [.directory(Keys.Database.likesDir), .directory(postId)]
        let values = [currentUid: userNewlyLikes ? 1 : 0]
        
        database.update(values, under: refs, completion: completion)
    }

    func fetchUserLikes(of postId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUid = auth.currentUserId else { return }
        let refs: [Reference] = [.directory(Keys.Database.likesDir), .directory(postId), .directory(currentUid)]
        
        database.fetchAll(under: refs) { (result: Result<Int?, Error>) in
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
    private func fetchPost(of uid: String?, _ completion: @escaping (Result<Post?, Error>) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.postsDir), .directory(userId), .directory(Keys.Database.contents)]
        
        database.fetchAll(under: refs) { [weak self] (result: Result<[String: Any]?, Error>) in
            switch result {
            case .success(let values):
                guard let values = values else {
                    completion(.success(nil))
                    return
                }
                values.forEach({ (key, value) in
                    guard let value = value as? [String: Any] else { return }
                    self?.generatePost(of: userId, postId: key, value: value) {
                        switch $0 {
                        case .success(let post): completion(.success(post))
                        case .failure(let error): completion(.failure(error))
                        }
                    }
                })
            default: return
            }
        }
    }
    
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
