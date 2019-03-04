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
    
    func fetchPost(at postId: String, of uid: String?, _ completion: @escaping (Result<PostObject?, Error>) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.postsDir), .directory(userId), .directory(postId)]

        database.fetchFromRoot(under: refs) { (result: Result<[String: Any]?, Error>) in
            switch result {
            case .success(let values):
                guard let values = values else {
                    completion(.success(nil))
                    return
                }
                
                do {
                    guard let posts = try PostMapper.map(values, shouldSort: false)[userId] else { return }
                    print("🥵Fetched posts: ", posts)
                    posts.forEach {
                        self.generatePostObj(of: userId, post: $0, completion: { (result) in
                            switch result {
                            case .success(let postObj): completion(.success(postObj))
                            case .failure(let error): completion(.failure(error))
                            }
                        })
                    }
                } catch {
                    print(error)
                }
            default: return
            }
        }
    }
    
    func fetchPost(of uid: String?, _ completion: @escaping (Result<PostObject?, Error>) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.postsDir), .directory(userId)]
        
        database.fetchFromRoot(under: refs) { (result: Result<[String: Any]?, Error>) in
            switch result {
            case .success(let values):
                guard let values = values else { return }
                
                var posts = [String: [Post]]()
                do {
                    posts = try PostMapper.map(values, shouldSort: false)
                } catch {
                    print(error)
                }
                
                posts[userId]?.forEach {
                    self.generatePostObj(of: userId, post: $0, completion: { (result) in
                        switch result {
                        case .success(let postObj):
                            completion(.success(postObj))
                        case .failure:
                            return
                        }
                    })
                }
                
            default: return
            }
        }
    }
    
    func fetchFollowingList(of uid: String?, _ completion: @escaping (Result<[String], Error>) -> Void) {
        profileService.fetchFollowingList(of: uid) { (result) in
            switch result {
            case .success(let followingUsers): completion(.success(followingUsers))
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func fetchPostWithPagination(of uid: String?, from postId: Any?, to limit: Int, with order: Post.Order, completion: @escaping (Result<([PostObject], Bool), Error>) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.postsDir), .directory(userId)]

        var postObjects: [PostObject] = []
        database.fetch(under: refs, from: postId, to: limit, orderBy: order) { (result: Result<([String: Any?], Bool), Error>) in
            switch result {
            case .success(let (rawValues, isPagingFinished)):
                self.serialQueue.async {
                    do {
                        guard let posts = try PostMapper.map(rawValues as [String : Any], shouldSort: true)[userId] else { return }
                        print("🥵Fetched posts: ", posts)
                        posts.forEach {
                            self.generatePostObj(of: userId, post: $0, completion: { (result) in
                                switch result {
                                case .success(let postObj):
                                    postObjects.append(postObj)
                                    if postObjects.count == posts.count {
                                        completion(.success((postObjects, isPagingFinished)))
                                    }
                                case .failure(let error): completion(.failure(error))
                                }
                            })
                        }

                    } catch {
                        print(error)
                    }
                }
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func fetchPostsCount(of uid: String?, _ completion: @escaping (Int) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.countsDir), .directory(userId), .directory(Keys.Database.Counts.post)]
        
        database.fetchAll(under: refs) { (result: Result<Int?, Error>) in
            switch result {
            case .success(let count): completion(count ?? 0)
            default: return
            }
        }
    }
    
    func changeLikes(_ postId: String, of uidWhoPosted: String, to userNewlyLikes: Bool, completion: @escaping (Error?) -> Void) {
        guard let currentUid = auth.currentUserId, currentUid != uidWhoPosted else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.likesDir), .directory(uidWhoPosted), .directory(postId)]
        
        if userNewlyLikes {
            let values = [currentUid: 1]
            database.update(values, under: refs, completion: completion)
        } else {
            let userRef = refs + [.directory(currentUid)]
            database.delete(from: userRef, completion: completion)
        }
    }
    
    func fetchUserLikes(_ postId: String, of uidWhoPosted: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUid = auth.currentUserId else { return }
        let refs: [Reference] = [.directory(Keys.Database.likesDir), .directory(uidWhoPosted), .directory(postId), .directory(currentUid)]
        
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
    private func generatePostObj(of uid: String, post: Post, completion: @escaping (Result<PostObject, Error>) -> Void) {
        profileService.fetchUserInfo(of: uid) { [unowned self] (result) in
            switch result {
            case .success(let userInfo):
                self.fetchUserLikes(post.id, of: userInfo.id) { (result) in
                    switch result {
                    case .success(let hasLiked):
                        let postObj = PostObject(post, userInfo, hasLiked: hasLiked)
                        completion(.success(postObj))
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

private class PostMapper {
    private struct Root: Decodable {
        let posts: [String: [String: Item]]
        
        var items: [String: [Post]] {
            return self.posts.reduce([String: [Post]]()) { (result, user) -> [String: [Post]] in
                let userPosts = user.value.compactMap({ (postKey, postItem) -> Post? in
                    return Post(postKey,
                                postItem.caption,
                                postItem.imageUrl,
                                postItem.imageWidth,
                                postItem.imageHeight,
                                postItem.creationDate)
                })
                var result = result
                result[user.key] = userPosts
                return result
            }
        }
    }
    
    private struct RootWithOrder: Decodable {
        let posts: [String: [String: [String: Item]]]
        
        var items: [String: [Post]] {
            return self.posts.reduce([String: [Post]]()) { (result, userWithOrder) -> [String: [Post]] in
                let posts = (0..<userWithOrder.value.count).compactMap({ (index) -> Post? in
                    guard let postInfo = userWithOrder.value["\(index)"]?.first else { return nil }
                    let post = Post(postInfo.key,
                                    postInfo.value.caption,
                                    postInfo.value.imageUrl,
                                    postInfo.value.imageWidth,
                                    postInfo.value.imageHeight,
                                    postInfo.value.creationDate)
                    return post
                })
                var result = result
                result[userWithOrder.key] = posts
                return result
            }
        }
    }
    
    private struct Item: Decodable {
        let caption: String
        let creationDate: Double
        let imageWidth: Float
        let imageHeight: Float
        let imageUrl: String
    }
    
    static func map(_ dictionary: [String: Any], shouldSort: Bool) throws -> [String: [Post]] {
        var parsedObject = [String: [Post]]()
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        if shouldSort {
            parsedObject = try JSONDecoder().decode(RootWithOrder.self, from: jsonData).items
        } else {
            parsedObject = try JSONDecoder().decode(Root.self, from: jsonData).items
        }
        return parsedObject
    }
}
