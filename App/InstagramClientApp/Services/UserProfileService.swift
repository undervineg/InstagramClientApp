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
    
    func loadUserInfo(of uid: String?, _ completion: @escaping (Result<User, UserProfileUseCase.Error>) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.usersDir), .directory(userId)]
        
        database.fetchAll(under: refs) { (result: Result<[String: Any]?, Error>) in
            switch result {
            case .success(let values):
                let email = values?[Keys.Database.Profile.email] as? String ?? ""
                let username = values?[Keys.Database.Profile.username] as? String ?? ""
                let profileImageUrl = values?[Keys.Database.Profile.image] as? String ?? ""
                
                let userInfo = User(id: userId, email: email, username: username, imageUrl: profileImageUrl)
                
                completion(.success(userInfo))
            case .failure:
                completion(.failure(.currentUserNotExist))
            }
        }
    }
    
    func fetchAllUsers(shouldOmitCurrentUser: Bool, _ completion: @escaping (Result<[User], Error>) -> Void) {
        let refs: [Reference] = [.directory(Keys.Database.usersDir)]
        
        database.fetchAll(under: refs) { [weak self] (result: Result<[String: Any]?, Error>) in
            switch result {
            case .success(let values):
                guard let values = values else { return }
                let users = values.compactMap({ (uid, uinfo) -> User? in
                    if shouldOmitCurrentUser, uid == self?.auth.currentUserId {
                        return nil
                    }
                    guard let uinfo = uinfo as? [String: Any] else { return nil }
                    let email = uinfo[Keys.Database.Profile.email] as? String ?? ""
                    let username = uinfo[Keys.Database.Profile.username] as? String ?? ""
                    let profileImageUrl = uinfo[Keys.Database.Profile.image] as? String ?? ""

                    return User(id: uid, email: email, username: username, imageUrl: profileImageUrl)
                })
                completion(.success(users))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func followUser(_ uid: String, _ completion: @escaping (UserProfileUseCase.Error?) -> Void) {
        guard let currentUserId = auth.currentUserId else { return }
        let refs: [Reference] = [.directory(Keys.Database.followingDir), .directory(currentUserId)]
        
        let values = [uid: 1]
        database.update(values, under: refs) { (error) in
            if error != nil {
                completion(.followError)
                return
            }
            completion(nil)
        }
    }
    
    func unfollowUser(_ uid: String, _ completion: @escaping (UserProfileUseCase.Error?) -> Void) {
        guard let currentUserId = auth.currentUserId else { return }
        let refs: [Reference] = [.directory(Keys.Database.followingDir), .directory(currentUserId), .directory(uid)]
        
        database.delete(from: refs) { (error) in
            if error != nil {
                completion(.unfollowError)
                return
            }
            completion(nil)
        }
    }
    
    func checkIsFollowing(_ uid: String, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUserId = auth.currentUserId else { return }
        let refs: [Reference] = [.directory(Keys.Database.followingDir), .directory(currentUserId), .directory(uid)]
        
        database.fetchAll(under: refs) { (result: Result<Int?, Error>) in
            switch result {
            case .success(let count):
                let isFollowing = (count ?? 0 > 0) ? true : false
                completion(.success(isFollowing))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchFollowingCount(of uid: String?, _ completion: @escaping (Int) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.followingDir), .directory(userId), .directory(Keys.Database.count)]
        
        database.fetchAll(under: refs) { (result: Result<Int?, Error>) in
            switch result {
            case .success(let count): completion(count ?? 0)
            default: return
            }
        }
    }
    
    func fetchFollowingList(of uid: String?, _ completion: @escaping (Result<[String], Error>) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [Reference.directory(Keys.Database.followingDir), .directory(userId)]
        
        database.fetchAll(under: refs) { (result: Result<[String: Int]?, Error>) in
            switch result {
            case .success(let followingUserData):
                guard let followingUserData = followingUserData else { return }
                let followingUidList = followingUserData.keys.map { $0 }
                completion(.success(followingUidList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func downloadProfileImage(from url: URL, completion: @escaping (Result<Data, UserProfileUseCase.Error>) -> Void) {
        networking.get(from: url) { (result) in
            switch result {
            case .success(let data):
                if let data = data {
                    completion(.success(data))
                }
            case .failure:
                completion(.failure(.profileImageNotExist))
            }
        }
    }
}

extension User.Order: HasKey, Sortable {
    var sortBy: Sort {
        switch self {
        case .email(let sort): return sort
        case .username(let sort): return sort
        }
    }
    
    var key: String {
        switch self {
        case .email: return Keys.Database.Profile.email
        case .username: return Keys.Database.Profile.username
        }
    }
}
