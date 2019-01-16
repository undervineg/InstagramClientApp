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
    static func fetchUserInfo(_ userId: String, completion: @escaping (User?) -> Void)
    static func savePost(userId: String, post: Post, completion: @escaping (Error?) -> Void)
}

extension Database: FirebaseDatabaseWrapper {
    private static let usersRef = "users"
    private static let postsRef = "posts"
    
    private static let emailKey = "email"
    private static let usernameKey = "username"
    private static let profileImageUrlKey = "profileImageUrl"
    
    private static let postImageKey = "imageUrl"
    private static let postCaptionKey = "caption"
    private static let postImageWidthKey = "imageWidth"
    private static let postImageHeightKey = "imageHeight"
    private static let postCreationDateKey = "creationDate"
    
    static func fetchUserInfo(_ userId: String, completion: @escaping (User?) -> Void) {
        database().reference().child(usersRef).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userInfoValues = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            let email = userInfoValues[emailKey] as? String ?? ""
            let username = userInfoValues[usernameKey] as? String ?? ""
            let profileImageUrl = userInfoValues[profileImageUrlKey] as? String ?? ""
            
            let userInfo = User(id: userId, email: email, username: username, profileImageUrl: profileImageUrl)
            completion(userInfo)
            
        }, withCancel: nil)
    }
    
    static func updateUser(userId: String, email: String, username: String, profileImageUrl: String, completion: @escaping (Error?) -> Void) {
        let userInfoValues = [emailKey: email, usernameKey: username, profileImageUrlKey: profileImageUrl]
        let ref = database().reference().child(usersRef).child(userId)
        ref.updateChildValues(userInfoValues) { (error, ref) in
            completion(error)
        }
    }
    
    static func savePost(userId: String, post: Post, completion: @escaping (Error?) -> Void) {
        let postValues = [
            postCaptionKey: post.caption,
            postImageKey: post.imageUrl ?? "",
            postImageWidthKey: post.imageWidth,
            postImageHeightKey: post.imageHeight,
            postCreationDateKey: post.creationDate
        ] as [String : Any]
        let ref = database().reference().child(postsRef).child(userId).childByAutoId()
        ref.updateChildValues(postValues) { (error, ref) in
            completion(error)
        }
    }
}
