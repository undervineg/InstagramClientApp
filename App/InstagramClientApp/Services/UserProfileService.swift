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
    private let messaging: FirebaseMessagingWrapper.Type
    private let networking: APIClient
    
    init(firebaseAuth: FirebaseAuthWrapper.Type,
         firebaseDatabase: FirebaseDatabaseWrapper.Type,
         firebaseMessaging: FirebaseMessagingWrapper.Type,
         networking: APIClient) {
        self.auth = firebaseAuth
        self.database = firebaseDatabase
        self.messaging = firebaseMessaging
        self.networking = networking
    }
    
    func fetchUserInfo(of uid: String?, _ completion: @escaping (Result<User, UserProfileUseCase.Error>) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.usersDir), .directory(userId)]
        
        database.fetchFromRoot(under: refs) { (result: Result<[String: Any]?, Error>) in
            switch result {
            case .success(let dataFromRoot):
                guard let dataFromRoot = dataFromRoot else {
                    completion(.failure(.currentUserNotExist))
                    return
                }
                do {
                    guard let userInfo = try UserMapper.map(dataFromRoot).first else { return }
                    completion(.success(userInfo))
                } catch {
                    print(error)
                }
            case .failure:
                completion(.failure(.currentUserNotExist))
            }
        }
    }
    
    func fetchAllUsers(shouldOmitCurrentUser: Bool, _ completion: @escaping (Result<[User], Error>) -> Void) {
        let refs: [Reference] = [.directory(Keys.Database.usersDir)]
        
        database.fetchFromRoot(under: refs) { [weak self] (result: Result<[String: Any]?, Error>) in
            switch result {
            case .success(let valuesWithKey):
                guard let valuesWithKey = valuesWithKey else { return }
                do {
                    let users = try UserMapper.map(valuesWithKey)
                    let filteredUsers
                        = shouldOmitCurrentUser ? users.filter { $0.id != self?.auth.currentUserId } : users
                    completion(.success(filteredUsers))
                } catch {
                    print(error)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func followUser(_ followingUid: String, _ completion: @escaping (UserProfileUseCase.Error?) -> Void) {
        guard let followerUid = auth.currentUserId else { return }
        let refs: [Reference] = [.directory(Keys.Database.followingDir), .directory(followingUid)]
        
        let values = [followerUid: 1]
        database.update(values, under: refs) { [weak self] (error) in
            if error != nil {
                completion(.followError)
                return
            }
            
            self?.messaging.subscribeTopic(.follower) { _ in
                completion(.subscribeTopicError)
            }
            
            completion(nil)
        }
    }
    
    func unfollowUser(_ followingUid: String, _ completion: @escaping (UserProfileUseCase.Error?) -> Void) {
        guard let followerUid = auth.currentUserId else { return }
        let refs: [Reference] = [.directory(Keys.Database.followingDir), .directory(followingUid), .directory(followerUid)]
        
        database.delete(from: refs) { [weak self] (error) in
            if error != nil {
                completion(.unfollowError)
                return
            }
            
            self?.messaging.unsubscribeTopic(.follower) { _ in
                completion(.unsubscribeTopicError)
            }
            
            completion(nil)
        }
    }
    
    func checkIsFollowing(_ followingUid: String, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let followerUid = auth.currentUserId else { return }
        let refs: [Reference] = [.directory(Keys.Database.followingDir), .directory(followingUid), .directory(followerUid)]
        
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
        
        let refs: [Reference] = [.directory(Keys.Database.countsDir), .directory(userId), .directory(Keys.Database.Counts.following)]
        
        database.fetchAll(under: refs) { (result: Result<Int?, Error>) in
            switch result {
            case .success(let count): completion(count ?? 0)
            default: return
            }
        }
    }
    
    func fetchFollowingList(of uid: String?, _ completion: @escaping (Result<[String], Error>) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [Reference.directory(Keys.Database.followingDir)]
        
        database.fetchAll(under: refs) { (result: Result<[String: [String: Int]]?, Error>) in
            switch result {
            case .success(let followedUserIds):
                guard let followedUserIds = followedUserIds else { return }
                let followingUids = followedUserIds.filter { (followedUserId, followingUserIds) -> Bool in
                    return followingUserIds.contains(where: { $0.key == userId })
                }.keys.map { $0 }
                completion(.success(followingUids))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func map(data: [String: Any]) -> [User] {
        return data.compactMap { (key, value) -> (key: String, value: [String: Any]?)? in
            let dictionaryValue = value as? [String: Any]
            return (key, dictionaryValue)
        }.map { (parsedData) -> User in
            let email = parsedData.value?[Keys.Database.Profile.email] as? String ?? ""
            let username = parsedData.value?[Keys.Database.Profile.username] as? String ?? ""
            let profileImageUrl = parsedData.value?[Keys.Database.Profile.image] as? String ?? ""
            
            return User(id: parsedData.key, email: email, username: username, imageUrl: profileImageUrl, fcmToken: nil)
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

private class UserMapper {
    private struct Root: Decodable {
        let users: [String: Item]
        
        var items: [User] {
            return self.users.map { (key, values) -> User in
                return User(id: key,
                            email: values.email,
                            username: values.username,
                            imageUrl: values.profileImageUrl,
                            fcmToken: values.fcmToken)
            }
        }
    }
    
    private struct Item: Decodable {
        let email: String
        let username: String
        let profileImageUrl: String
        let fcmToken: String?
    }
    
    static func map(_ dictionary: [String: Any]) throws -> [User] {
        var users = [User]()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let parsedObject = try JSONDecoder().decode(Root.self, from: jsonData)
            users = parsedObject.items
        } catch {
            throw error
        }
        return users
    }
}
