//
//  UserEntity.swift
//  InstagramEngine
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public struct UserEntity: Equatable {
    public let id: String
    public let email: String
    public let username: String
    
    public init(id: String, email: String, username: String) {
        self.id = id
        self.email = email
        self.username = username
    }
}
