//
//  UserProfileClientAdapter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

final class UserProfileClientAdapter: UserProfileClient {
    
    private let auth: FirebaseAuthWrapper.Type
    private let database: FirebaseDatabaseWrapper.Type
    private let storage: FirebaseStorageWrapper.Type
    
    init(firebaseAuth: FirebaseAuthWrapper.Type,
         firebaseDatabase: FirebaseDatabaseWrapper.Type,
         firebaseStorage: FirebaseStorageWrapper.Type) {
        self.auth = firebaseAuth
        self.database = firebaseDatabase
        self.storage = firebaseStorage
    }
    
    func loadCurrentUserInfo(_ completion: @escaping (Result<UserEntity, UserProfileUseCase.Error>) -> Void) {
        guard let uid = auth.currentUserId else {
            completion(.failure(.currentUserIDNotExist))
            return
        }
        database.fetchUserInfo(uid) { (userEntity) in
            if let user = userEntity {
                completion(.success(user))
            } else {
                completion(.failure(.currentUserNotExist))
            }
        }
    }
}
