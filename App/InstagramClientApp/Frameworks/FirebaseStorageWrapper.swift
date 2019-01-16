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
    static func uploadShareImageData(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void)
}

extension Storage: FirebaseStorageWrapper {
    private static let profileImagesRef = "profile_images"
    private static let postImagesRef = "post_images"
    
    static func uploadProfileImageData(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        uploadImageData(imageData, at: profileImagesRef, completion: completion)
    }
    
    static func uploadShareImageData(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        uploadImageData(imageData, at: postImagesRef, completion: completion)
    }
    
    private static func uploadImageData(_ imageData: Data, at folderName: String?, completion: @escaping (Result<String, Error>) -> Void) {
        let filename = UUID().uuidString
        let storageRef = storage().reference()
        let imageStorageRef = (folderName == nil) ? storageRef.child(filename) : storageRef.child(folderName!).child(filename)
        
        imageStorageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            }
            imageStorageRef.downloadURL(completion: { (url, error) in
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
