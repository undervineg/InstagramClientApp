//
//  NotificationService.swift
//  InstagramClientApp
//
//  Created by 심승민 on 21/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

final class NotificationService: NotificationClient {
    private let database: FirebaseDatabaseWrapper.Type
    private let auth: FirebaseAuthWrapper.Type
    private let profileService: UserProfileService
    private let postService: PostService
    
    init(database: FirebaseDatabaseWrapper.Type,
         auth: FirebaseAuthWrapper.Type,
         profileService: UserProfileService,
         postService: PostService) {
        self.database = database
        self.auth = auth
        self.profileService = profileService
        self.postService = postService
    }
    
    func fetchAllNotifications(of uid: String?, _ completion: @escaping (Result<PushNotification, Error>) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.notificationsDir), .directory(userId)]
        
        database.fetchAll(under: refs) { [weak self] (result: Result<[String: Any]?, Error>) in
            switch result {
            case .success(let values):
                guard let values = values else { return }
                values.forEach({ (key, value) in
                    guard
                        let value = value as? [String: Any],
                        let notification = self?.createMessage(key, value) else { return }
                    completion(.success(notification))
//                    self?.generateNotification(notificationId: key, value: value) {
//                        switch $0 {
//                        case .success(let notification): completion(.success(notification))
//                        case .failure(let error): completion(.failure(error))
//                        }
//                    }
                })
            default: return
            }
        }
    }
    
    func readAllNotifications(of uid: String?, _ completion: @escaping (Error?) -> Void) {
        updateUnreadCount(uid, 0) { [weak self] (error) in
            if let error = error {
                print(error)
            }
            self?.resetBadge()
        }
    }
    
    func readNotification(of uid: String?, at notificationId: String, _ completion: @escaping (Error?) -> Void) {
        
    }
    
    private func updateUnreadCount(_ uid: String?, _ count: Int, _ completion: @escaping (Error?) -> Void) {
        guard let userId = (uid == nil) ? auth.currentUserId : uid else { return }
        
        let refs: [Reference] = [.directory(Keys.Database.countsDir), .directory(userId)]
        
        let key = Keys.Database.Counts.notification
        database.update([key: count], under: refs, completion: completion)
    }
    
    private func setBadge(to badgeNumber: Int) {
        UIApplication.shared.applicationIconBadgeNumber = badgeNumber
    }
    
    private func resetBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: Private Methods
//    private func generateNotification(notificationId: String, value: [String: Any], completion: @escaping (Result<PushNotification, Error>) -> Void) {
//        let relatedUserId = value[Keys.Database.Notifications.relatedUserId] as? String
//        let relatedPostId = value[Keys.Database.Notifications.relatedPostId] as? String
//
//        profileService.fetchUserInfo(of: relatedUserId) { [unowned self] (result) in
//            switch result {
//            case .success(let user):
//                if let relatedPostId = relatedPostId {
//                    self.postService.fetchPost(of: relatedUserId, at: relatedPostId) { (result) in
//                        switch result {
//                        case .success(let post):
//                            let notification = self.createMessage(notificationId, value, user, post?.data)
//                            completion(.success(notification))
//                        case .failure(let error): completion(.failure(error))
//                        }
//                    }
//                } else {
//                    let notification = self.createMessage(notificationId, value, user, nil)
//                    completion(.success(notification))
//                }
//
//            case .failure(let error): completion(.failure(error))
//            }
//        }
//    }
    
    private func createMessage(_ notificationId: String, _ value: [String: Any]) -> PushNotification {
        let type = value[Keys.Database.Notifications.type] as? Int ?? 0
        let title = value[Keys.Database.Notifications.title] as? String
        let body = value[Keys.Database.Notifications.body] as? String ?? ""
        let emphasizeIndices = value[Keys.Database.Notifications.emphasizeIndices] as? [Int]
        let creationDate = value[Keys.Database.Notifications.creationDate] as? Double ?? 0.0
        let readDate = value[Keys.Database.Notifications.readDate] as? Double ?? 0.0
        let profileImageUrl = value[Keys.Database.Notifications.profileImageUrl] as? String ?? ""
        let profileLink = value[Keys.Database.Notifications.profileLink] as? String ?? ""
        let detailImageUrls = value[Keys.Database.Notifications.detailImageUrls] as? [String]
        let detailLinks = value[Keys.Database.Notifications.detailLinks] as? [String]
        let detailButtonType = value[Keys.Database.Notifications.detailButtonType] as? Int
        
        return PushNotification(notificationId, type, title, body, emphasizeIndices, creationDate, readDate, profileImageUrl, profileLink, detailImageUrls, detailLinks, detailButtonType)
    }
}
