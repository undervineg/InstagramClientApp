//
//  ShareService.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import InstagramEngine

final class ShareService: SharePhotoClient {
    
    struct Keys {
        static let postsDir = "posts"
        static let postImagesDir = "post_images"
        
        struct Post {
            static let caption = "caption"
            static let image = "imageUrl"
            static let imageWidth = "imageWidth"
            static let imageHeight = "imageHeight"
            static let creationDate = "creationDate"
        }
    }
    
    private let storage: FirebaseStorageWrapper.Type
    private let database: FirebaseDatabaseWrapper.Type
    private let auth: FirebaseAuthWrapper.Type
    
    init(storage: FirebaseStorageWrapper.Type,
         database: FirebaseDatabaseWrapper.Type,
         auth: FirebaseAuthWrapper.Type) {
        self.storage = storage
        self.database = database
        self.auth = auth
    }
    
    func share(data: Data, post: Post, completion: @escaping (Error?) -> Void) {
        let filename = UUID().uuidString
        let refs: [Reference] = [
            .directory(Keys.postImagesDir),
            .directory(filename)
        ]
        
        storage.uploadImage(data, to: refs) { (result) in
            switch result {
            case .success(let url):
                if let userId = self.auth.currentUserId {
                    
                    let postValues = [
                        Keys.Post.caption: post.caption,
                        Keys.Post.image: url,
                        Keys.Post.imageWidth: post.imageWidth,
                        Keys.Post.imageHeight: post.imageHeight,
                        Keys.Post.creationDate: post.creationDate
                        ] as [String: Any]
                    
                    let refs: [Reference] = [
                        .directory(Keys.postsDir),
                        .directory(userId),
                        .autoId
                    ]
                    
                    self.database.update(postValues, to: refs, completion: completion)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
}
