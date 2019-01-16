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
    
    func share(data: Data, post: Post, completion: @escaping (Error?) -> Void) {
        storage.uploadShareImageData(data) { [weak self] (result) in
            switch result {
            case .success(let url):
                if let userId = self?.auth.currentUserId {
                    let postWithUrl = Post(post.caption, url, post.imageWidth, post.imageHeight, post.creationDate)
                    self?.database.savePost(userId: userId, post: postWithUrl, completion: completion)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
}
