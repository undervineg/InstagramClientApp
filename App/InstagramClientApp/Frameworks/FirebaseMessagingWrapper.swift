//
//  FirebaseMessagingWrapper.swift
//  InstagramClientApp
//
//  Created by 심승민 on 01/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import FirebaseMessaging

enum PushNotificationTopic {
    case follower
    
    var name: String {
        switch self {
        case .follower: return "followers"
        }
    }
}

protocol FirebaseMessagingWrapper {
    static var userFcmToken: String? { get }
 
    static func subscribeTopic(_ topic: PushNotificationTopic, _ completion: @escaping (Error) -> Void)
    static func unsubscribeTopic(_ topic: PushNotificationTopic, _ completion: @escaping (Error) -> Void)
}

extension Messaging: FirebaseMessagingWrapper {
    static var userFcmToken: String? {
        return messaging().fcmToken
    }
    
    static func subscribeTopic(_ topic: PushNotificationTopic, _ completion: @escaping (Error) -> Void) {
        messaging().subscribe(toTopic: topic.name) { err in
            if let err = err {
                completion(err)
            }
        }
    }
    
    static func unsubscribeTopic(_ topic: PushNotificationTopic, _ completion: @escaping (Error) -> Void) {
        messaging().unsubscribe(fromTopic: topic.name) { err in
            if let err = err {
                completion(err)
            }
        }
    }
}
