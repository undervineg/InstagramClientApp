//
//  FirebaseStorageWrapper.swift
//  InstagramClientApp
//
//  Created by 심승민 on 03/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseStorage
import InstagramEngine

protocol FirebaseStorageWrapper {
    static func uploadProfileImageData(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void)
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
