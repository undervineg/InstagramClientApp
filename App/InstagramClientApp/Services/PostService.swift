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
    
    func fetchPost(_ completion: @escaping (Result<Post, HomeFeedUseCase.Error>) -> Void) {
        guard let uid = auth.currentUserId else {
            completion(.failure(.userIDNotExist))
            return
        }
        
        let refs: [Reference] = [Reference.directory(Keys.Database.postsDir), .directory(uid)]
        
        database.fetchAll(under: refs) { [weak self] (result) in
            switch result {
            case .success(let values):
                values.forEach({ (key, value) in
                    guard let value = value as? [String: Any] else { return }
                    self?.generatePost(of: uid, value: value, completion: completion)
                })
            default: return
            }
        }
    }
    
    func fetchPost(with order: HomeFeedUseCase.Order, _ completion: @escaping (Result<Post, HomeFeedUseCase.Error>) -> Void) {
        guard let uid = auth.currentUserId else {
            completion(.failure(.userIDNotExist))
            return
        }
        
        let refs: [Reference] = [Reference.directory(Keys.Database.postsDir), .directory(uid)]
        
        database.fetch(under: refs, orderBy: order) { [weak self] (result) in
            switch result {
            case .success(let value):
                self?.generatePost(of: uid, value: value, completion: completion)
            default: return
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
    private func generatePost(of uid: String, value: [String: Any], completion: @escaping (Result<Post, HomeFeedUseCase.Error>) -> Void) {
        profileService.loadUserInfo(of: uid) { (result) in
            switch result {
            case .success(let userInfo):
                let caption = value[Keys.Database.Post.caption] as? String ?? ""
                let imageUrl = value[Keys.Database.Post.image] as? String ?? ""
                let imageWidth = value[Keys.Database.Post.imageWidth] as? Float ?? 0.0
                let imageHeight = value[Keys.Database.Post.imageHeight] as? Float ?? 0.0
                let creationDate = value[Keys.Database.Post.creationDate] as? Double ?? 0.0
                
                let post = Post(userInfo, caption, imageUrl, imageWidth, imageHeight, creationDate)
                completion(.success(post))
            case .failure:
                completion(.failure(.userIDNotExist))
            }
        }
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
        case .creationDate: return Keys.Database.Post.creationDate
        case .caption: return Keys.Database.Post.caption
        }
    }
}
