//
//  FirebaseDatabaseWrapper.swift
//  InstagramClientApp
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseDatabase
import InstagramEngine

protocol FirebaseDatabaseWrapper {
    static func updateUser(userId: String, email: String, username: String, profileImageUrl: String, completion: @escaping (Error?) -> Void)
    static func fetchUserInfo(_ userId: String) -> UserEntity?
}

extension Database: FirebaseDatabaseWrapper {
    private static let usersRef = "users"
    private static let emailKey = "email"
    private static let usernameKey = "username"
    private static let profileImageUrlKey = "profileImageUrl"
    
    static func fetchUserInfo(_ userId: String) -> UserEntity? {
        var userInfo: UserEntity?
        database().reference().child(usersRef).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userInfoValues = snapshot.value as? [String: Any] else { return }
            let email = userInfoValues[emailKey] as? String ?? ""
            let username = userInfoValues[usernameKey] as? String ?? ""
            let profileImageUrl = userInfoValues[profileImageUrlKey] as? String ?? ""
            
            userInfo = UserEntity(id: userId, email: email, username: username, profileImageUrl: profileImageUrl)
        }, withCancel: nil)
        
        return userInfo
    }
    
    static func updateUser(userId: String, email: String, username: String, profileImageUrl: String, completion: @escaping (Error?) -> Void) {
        let userInfoValues = [emailKey: email, usernameKey: username, profileImageUrlKey: profileImageUrl]
        let userInfoWithId = [userId: userInfoValues]
        database().reference().child(usersRef).updateChildValues(userInfoWithId) { (error, ref) in
            completion(error)
        }
    }
}
