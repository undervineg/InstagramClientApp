//
//  Post.swift
//  InstagramEngine
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol HasImageUrl {
    var imageUrl: String { get }
}

public final class PostObject {
    public let uuid: UUID
    public var data: Post
    public let user: User
    public var hasLiked: Bool = false
    
    public init(_ data: Post, _ user: User, hasLiked: Bool) {
        self.uuid = UUID()
        self.data = data
        self.user = user
        self.hasLiked = hasLiked
    }
}

public struct Post: HasImageUrl {
    public let id: String
    public let caption: String
    public let imageUrl: String
    public let imageWidth: Float
    public let imageHeight: Float
    public let creationDate: Date
    
    public init(_ id: String, _ caption: String, _ imageUrl: String, _ imageWidth: Float, _ imageHeight: Float, _ creationDate: Double) {
        self.id = id
        self.caption = caption
        self.imageUrl = imageUrl
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.creationDate = Date(timeIntervalSince1970: creationDate)
    }
    
    public enum Order {
        case caption(Sort)
        case creationDate(Sort)
        
        public func switchSortingForPagination() -> Order {
            switch self {
            case .caption(let sort):
                switch sort {
                case .ascending: return .caption(.descending)
                case .descending: return .caption(.ascending)
                }
            case .creationDate(let sort):
                switch sort {
                case .ascending: return .creationDate(.descending)
                case .descending: return .creationDate(.ascending)
                }
            }
        }
    }
}
