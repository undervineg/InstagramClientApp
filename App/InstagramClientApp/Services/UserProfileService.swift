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
    
    func loadCurrentUserInfo(_ completion: @escaping (Result<User, UserProfileUseCase.Error>) -> Void) {
        guard let uid = auth.currentUserId else {
            completion(.failure(.currentUserIDNotExist))
            return
        }
        
        loadUserInfo(of: uid, completion)
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
    
    func loadUserInfo(of uid: String, _ completion: @escaping (Result<User, UserProfileUseCase.Error>) -> Void) {
        let refs: [Reference] = [.directory(Keys.Database.usersDir), .directory(uid)]
        
        database.fetchAll(under: refs) { (result) in
            switch result {
            case .success(let values):
                let email = values[Keys.Database.Profile.email] as? String ?? ""
                let username = values[Keys.Database.Profile.username] as? String ?? ""
                let profileImageUrl = values[Keys.Database.Profile.image] as? String ?? ""
                
                let userInfo = User(id: uid, email: email, username: username, profileImageUrl: profileImageUrl)
                
                completion(.success(userInfo))
            case .failure:
                completion(.failure(.currentUserNotExist))
            }
        }
    }
    
    func fetchAllUsers(_ completion: @escaping (Result<[User], Error>) -> Void) {
        let refs: [Reference] = [.directory(Keys.Database.usersDir)]
        
        database.fetchAll(under: refs) { (result) in
            switch result {
            case .success(let values):
                let users = values.compactMap({ (uid, uinfo) -> User? in
                    guard let uinfo = uinfo as? [String: Any] else { return nil }
                    let email = uinfo[Keys.Database.Profile.email] as? String ?? ""
                    let username = uinfo[Keys.Database.Profile.username] as? String ?? ""
                    let profileImageUrl = uinfo[Keys.Database.Profile.image] as? String ?? ""

                    return User(id: uid, email: email, username: username, profileImageUrl: profileImageUrl)
                })
                completion(.success(users))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
