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

    struct Keys {
        static let postsDir = "posts"
        
        struct Post {
            static let caption = "caption"
            static let image = "imageUrl"
            static let imageWidth = "imageWidth"
            static let imageHeight = "imageHeight"
            static let creationDate = "creationDate"
        }
    }
    
    private let auth: FirebaseAuthWrapper.Type
    private let database: FirebaseDatabaseWrapper.Type
    private let networking: APIClient
    
    init(firebaseAuth: FirebaseAuthWrapper.Type,
         firebaseDatabase: FirebaseDatabaseWrapper.Type,
         networking: APIClient) {
        self.auth = firebaseAuth
        self.database = firebaseDatabase
        self.networking = networking
    }
    
    func fetchPost(_ completion: @escaping (Result<Post, HomeFeedUseCase.Error>) -> Void) {
        guard let uid = auth.currentUserId else {
            completion(.failure(.currentUserIDNotExist))
            return
        }
        
        let refs: [Reference] = [Reference.directory(Keys.postsDir), .directory(uid)]
        
        database.fetchAll(under: refs) { (result) in
            switch result {
            case .success(let values):
                values.forEach({ (key, value) in
                    guard let value = value as? [String: Any] else { return }
                    let post = self.generatePost(value: value)
                    completion(.success(post))
                })
            default: break
            }
        }
    }
    
    func fetchPost(with order: HomeFeedUseCase.Order, _ completion: @escaping (Result<Post, HomeFeedUseCase.Error>) -> Void) {
        guard let uid = auth.currentUserId else {
            completion(.failure(.currentUserIDNotExist))
            return
        }
        
        let refs: [Reference] = [Reference.directory(Keys.postsDir), .directory(uid)]
        
        database.fetch(under: refs, orderBy: order) { (result) in
            switch result {
            case .success(let value):
                let post = self.generatePost(value: value)
                completion(.success(post))
            default: break
            }
        }
    }
    
    func downloadPostImage(from url: URL, completion: @escaping (Result<Data, HomeFeedUseCase.Error>) -> Void) {
        networking.get(from: url) { (result) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                completion(.failure(.postImageNotFound))
            }
        }
    }
    
    
    // MARK: Private Methods
    private func generatePost(value: [String: Any]) -> Post {
        let caption = value[Keys.Post.caption] as? String ?? ""
        let imageUrl = value[Keys.Post.image] as? String ?? ""
        let imageWidth = value[Keys.Post.imageWidth] as? Float ?? 0.0
        let imageHeight = value[Keys.Post.imageHeight] as? Float ?? 0.0
        let creationDate = value[Keys.Post.creationDate] as? Double ?? 0.0
        
        return Post(caption, imageUrl, imageWidth, imageHeight, creationDate)
    }
}

extension HomeFeedUseCase.Order: HasKey, Sortable {
    var sortBy: Sort {
        switch self {
        case .creationDate(let sort): return sort
        case .caption(let sort): return sort
        }
    }
    
    var key: String {
        switch self {
        case .creationDate: return PostService.Keys.Post.creationDate
        case .caption: return PostService.Keys.Post.caption
        }
    }
}
