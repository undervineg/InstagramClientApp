//
//  UserProfileClientAdapter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine
import Foundation

final class UserProfileService: UserProfileClient {
    
    struct Keys {
        static let usersDir = "users"
        static let postsDir = "posts"
        
        struct Profile {
            static let email = "email"
            static let username = "username"
            static let image = "profileImageUrl"
        }
        
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
    private let storage: FirebaseStorageWrapper.Type
    private let networking: APIClient
    
    init(firebaseAuth: FirebaseAuthWrapper.Type,
         firebaseDatabase: FirebaseDatabaseWrapper.Type,
         firebaseStorage: FirebaseStorageWrapper.Type,
         networking: APIClient) {
        self.auth = firebaseAuth
        self.database = firebaseDatabase
        self.storage = firebaseStorage
        self.networking = networking
    }
    
    func loadCurrentUserInfo(_ completion: @escaping (Result<User, UserProfileUseCase.Error>) -> Void) {
        guard let uid = auth.currentUserId else {
            completion(.failure(.currentUserIDNotExist))
            return
        }
        
        let refs: [Reference] = [.directory(Keys.usersDir), .directory(uid)]
        
        database.fetch(from: refs) { (result) in
            switch result {
            case .success(let values):
                let email = values[Keys.Profile.email] as? String ?? ""
                let username = values[Keys.Profile.username] as? String ?? ""
                let profileImageUrl = values[Keys.Profile.image] as? String ?? ""
                
                let userInfo = User(id: uid, email: email, username: username, profileImageUrl: profileImageUrl)
                
                completion(.success(userInfo))
            case .failure:
                completion(.failure(.currentUserNotExist))
            }
        }
    }
    
    func downloadProfileImage(from url: URL, completion: @escaping (Result<Data, UserProfileUseCase.Error>) -> Void) {
        networking.get(from: url) { (result) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                completion(.failure(.profileImageNotExist))
            }
        }
    }
    
    func logout(_ completion: @escaping (Error?) -> Void) {
         auth.logout(completion)
    }
    
    func fetchPosts(_ completion: @escaping (Result<[Post], UserProfileUseCase.Error>) -> Void) {
        guard let uid = auth.currentUserId else {
            completion(.failure(.currentUserIDNotExist))
            return
        }
        
        let refs: [Reference] = [Reference.directory(Keys.postsDir), .directory(uid)]
        
        database.fetch(from: refs) { (result) in
            switch result {
            case .success(let values):
                let posts = values.compactMap({ (_, value) -> Post? in
                    guard let value = value as? [String: Any] else { return nil }
                    
                    let caption = value[Keys.Post.caption] as? String ?? ""
                    let imageUrl = value[Keys.Post.image] as? String ?? ""
                    let imageWidth = value[Keys.Post.imageWidth] as? Float ?? 0.0
                    let imageHeight = value[Keys.Post.imageHeight] as? Float ?? 0.0
                    let creationDate = value[Keys.Post.creationDate] as? Double ?? 0.0
                    
                    return Post(caption, imageUrl, imageWidth, imageHeight, creationDate)
                })
                
                completion(.success(posts))
                
            default: break
            }
        }
    }
    
    func downloadPostImage(from url: URL, completion: @escaping (Result<Data, UserProfileUseCase.Error>) -> Void) {
        networking.get(from: url) { (result) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                completion(.failure(.postImageNotFound))
            }
        }
    }
}
