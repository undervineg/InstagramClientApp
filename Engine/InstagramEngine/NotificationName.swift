//
//  NotificationName.swift
//  InstagramEngine
//
//  Created by 심승민 on 22/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public struct NotificationName {
    public static let shareNewFeed = Notification.Name("shareNewFeed")
    public static let followNewUser = Notification.Name("followNewUser")
    public static let unfollowOldUser = Notification.Name("unfollowOldUser")
}
