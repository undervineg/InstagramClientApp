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
        
        struct Profile {
            static let email = "email"
            static let username = "username"
            static let image = "profileImageUrl"
        }
        
        struct Post {
            static let uid = "userId"
            static let caption = "caption"
            static let image = "imageUrl"
            static let imageWidth = "imageWidth"
            static let imageHeight = "imageHeight"
            static let creationDate = "creationDate"
        }
    }
    
    struct Storage {
        static let profileImagesDir = "profile_images"
        static let postImagesDir = "post_images"
    }
}
