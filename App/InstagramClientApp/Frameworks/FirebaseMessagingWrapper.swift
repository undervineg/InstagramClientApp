//
//  FirebaseMessagingWrapper.swift
//  InstagramClientApp
//
//  Created by 심승민 on 01/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import FirebaseMessaging

protocol FirebaseMessagingWrapper {
    static var userFcmToken: String? { get }
}

extension Messaging: FirebaseMessagingWrapper {
    static var userFcmToken: String? {
        return messaging().fcmToken
    }
}
