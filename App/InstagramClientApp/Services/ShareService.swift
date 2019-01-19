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
    
    func share(_ data: Data, _ caption: String, _ imageWidth: Float, _ imageHeight: Float, _ uploadDate: Double, completion: @escaping (Error?) -> Void) {
        let filename = UUID().uuidString
        let refs: [Reference] = [
            .directory(Keys.Storage.postImagesDir),
            .directory(filename)
        ]
        
        storage.uploadImage(data, to: refs) { (result) in
            switch result {
            case .success(let url):
                if let userId = self.auth.currentUserId {
                    
                    let postValues = [
                        Keys.Database.Post.caption: caption,
                        Keys.Database.Post.image: url,
                        Keys.Database.Post.imageWidth: imageWidth,
                        Keys.Database.Post.imageHeight: imageHeight,
                        Keys.Database.Post.creationDate: uploadDate
                        ] as [String: Any]
                    
                    let refs: [Reference] = [
                        .directory(Keys.Database.postsDir),
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
