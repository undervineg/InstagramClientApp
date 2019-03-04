//
//  Comment.swift
//  InstagramEngine
//
//  Created by 심승민 on 25/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public final class CommentObject {
    public let uuid: UUID
    public var data: Comment
    
    public init(_ data: Comment) {
        self.uuid = UUID()
        self.data = data
    }
}

public struct Comment {
    public let user: User
    public let text: String
    public let creationDate: Date
    
    public init(_ user: User, _ text: String, _ creationDate: Double) {
        self.user = user
        self.text = text
        self.creationDate = Date(timeIntervalSince1970: creationDate)
    }
    
    public enum Order {
        case creationDate(Sort)
    }
}
