//
//  CommentsService.swift
//  InstagramClientApp
//
//  Created by 심승민 on 25/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import InstagramEngine

final class CommentsService: CommentsClient {
    private let database: FirebaseDatabaseWrapper.Type
    private let auth: FirebaseAuthWrapper.Type
    private let profileService: UserProfileService
    
    init(database: FirebaseDatabaseWrapper.Type,
         auth: FirebaseAuthWrapper.Type,
         profileService: UserProfileService) {
        self.database = database
        self.auth = auth
        self.profileService = profileService
    }
    
    func fetchComments(postId: String, with order: Comment.Order, _ completion: @escaping (Result<Comment, Error>) -> Void) {
        let refs: [Reference] = [.directory(Keys.Database.commentsDir), .directory(postId)]
        
        database.fetch(under: refs, orderBy: order) { (result: Result<(String, [String: Any]), Error>) in
            switch result {
            case .success(let (_, commentValues)):
                self.generateComment(value: commentValues, completion: completion)
            default: return
            }
        }
    }
    
    func saveComment(_ commentText: String, _ submitDate: Double, forPost postId: String, _ completion: @escaping (Error?) -> Void) {
        guard let uid = auth.currentUserId else { return }
        
        let values = [
            Keys.Database.Comment.uid: uid,
            Keys.Database.Comment.text: commentText,
            Keys.Database.Comment.creationDate: submitDate
            ] as [String: Any]
        
        let refs: [Reference] = [.directory(Keys.Database.commentsDir), .directory(postId), .autoId]
        
        database.update(values, under: refs, completion: completion)
    }
    
    // MARK: Private Methods
    private func generateComment(value: [String: Any], completion: @escaping (Result<Comment, Error>) -> Void) {
        guard let uid = value[Keys.Database.Comment.uid] as? String else { return }
        
        profileService.loadUserInfo(of: uid) { (result) in
            switch result {
            case .success(let userInfo):
                let text = value[Keys.Database.Comment.text] as? String ?? ""
                let creationDate = value[Keys.Database.Comment.creationDate] as? Double ?? 0.0

                let comment = Comment(userInfo, text, creationDate)
                completion(.success(comment))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension Comment.Order: HasKey, Sortable {
    var sortBy: Sort {
        switch self {
        case .creationDate(let sort): return sort
        }
    }
    
    var key: String {
        switch self {
        case .creationDate: return Keys.Database.Comment.creationDate
        }
    }
}
