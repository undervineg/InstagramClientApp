//
//  Keys.swift
//  InstagramClientApp
//
//  Created by 심승민 on 19/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

struct Keys {
    struct Database {
        static let usersDir = "users"
        static let postsDir = "posts"
        static let followingDir = "following"
        static let commentsDir = "comments"
        static let likesDir = "likes"
        static let notificationsDir = "notifications"
        static let countsDir = "counts"
        
        struct Counts {
            static let post = "post"
            static let following = "following"
            static let follower = "follower"
            static let notification = "unreadNotification"
        }
        
        struct Notifications {
            static let type = "type"
            static let title = "title"
            static let body = "body"
            static let emphasizeIndices = "emphasizeIndices"
            static let creationDate = "creationDate"
            static let readDate = "readDate"
            static let profileImageUrl = "profileImageUrl"
            static let profileLink = "profileLink"
            static let detailImageUrls = "detailImageUrls"
            static let detailLinks = "detailLinks"
            static let detailButtonType = "detailButtonType"
        }
        
        struct Profile {
            static let email = "email"
            static let username = "username"
            static let image = "profileImageUrl"
            static let fcmToken = "fcmToken"
        }
        
        struct Post {
            static let caption = "caption"
            static let image = "imageUrl"
            static let imageWidth = "imageWidth"
            static let imageHeight = "imageHeight"
            static let creationDate = "creationDate"
        }
        
        struct Comment {
            static let uid = "userId"
            static let text = "text"
            static let creationDate = "creationDate"
        }
        
        struct Likes {
            
        }
    }
    
    struct Storage {
        static let profileImagesDir = "profile_images"
        static let postImagesDir = "post_images"
    }
    
    struct UserDefaults {
        static let fcmToken = "fcmToken"
    }
}
