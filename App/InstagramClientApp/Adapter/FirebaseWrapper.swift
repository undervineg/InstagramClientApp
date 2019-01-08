//
//  FirebaseWrapper.swift
//  InstagramClientApp
//
//  Created by 심승민 on 03/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import InstagramEngine

protocol FirebaseAuthWrapper {
    static var currentUserId: String? { get }
    
    static func registerUser(email: String, password: String, completion: @escaping (Result<(id: String, email: String?), Error>) -> Void)
}

protocol FirebaseDatabaseWrapper {
    static func updateUser(userId: String, email: String, username: String, profileImageUrl: String, completion: @escaping (Error?) -> Void)
    static func fetchUserInfo(_ userId: String) -> UserEntity?
}

protocol FirebaseStorageWrapper {
    static func uploadProfileImageData(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void)
}

extension Auth: FirebaseAuthWrapper {
    static var currentUserId: String? {
        return auth().currentUser?.uid
    }
    
    static func registerUser(email: String, password: String, completion: @escaping (Result<(id: String, email: String?), Error>) -> Void) {
        auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
            }
            if let result = result {
                let user = result.user
                completion(.success((user.uid, user.email)))
            }
        }
    }
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

extension Storage: FirebaseStorageWrapper {
    private static let profileImagesRef = "profile_images"
    
    static func uploadProfileImageData(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let filename = UUID().uuidString
        let profileImageStorageRef = storage().reference().child(profileImagesRef).child(filename)
        
        profileImageStorageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            }
            profileImageStorageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    completion(.failure(error))
                }
                guard let url = url else {
                    let noURLError = NSError(domain: "Download URL Not Exist", code: 0)
                    completion(.failure(noURLError))
                    return
                }
                completion(.success(url.absoluteString))
            })
        }
    }
    
}
