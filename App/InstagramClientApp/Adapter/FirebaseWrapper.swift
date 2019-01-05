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
    static func registerUser(email: String, password: String, completion: @escaping (Result<(id: String, email: String?), Error>) -> Void)
}

protocol FirebaseDatabaseWrapper {
    static func updateUser(with userInfo: [String : Any], completion: @escaping (Error?) -> Void)
}

protocol FirebaseStorageWrapper {
    static func uploadProfileImageData(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void)
}

extension Auth: FirebaseAuthWrapper {
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
    static func updateUser(with userInfo: [String : Any], completion: @escaping (Error?) -> Void) {
        database().reference().child("users").updateChildValues(userInfo) { (error, ref) in
            completion(error)
        }
    }
}

extension Storage: FirebaseStorageWrapper {
    static func uploadProfileImageData(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let filename = UUID().uuidString
        let profileImageStorageRef = storage().reference().child("profile_images").child(filename)
        
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
