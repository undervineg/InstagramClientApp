//
//  User.swift
//  InstagramEngine
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public final class UserObject {
    public let uuid: UUID
    public var data: User
    
    public init(_ data: User) {
        self.uuid = UUID()
        self.data = data
    }
}

public struct User: Equatable, HasImageUrl {
    public let id: String
    public let email: String
    public let username: String
    public let imageUrl: String
    
    public init(id: String, email: String, username: String, imageUrl: String) {
        self.id = id
        self.email = email
        self.username = username
        self.imageUrl = imageUrl
    }
    
    public enum Order {
        case email(Sort)
        case username(Sort)
    }
}
