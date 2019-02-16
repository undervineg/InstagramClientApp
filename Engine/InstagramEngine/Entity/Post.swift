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
    
    public init(_ data: Post) {
        self.uuid = UUID()
        self.data = data
    }
}

public struct Post: HasImageUrl {
    public let id: String
    public let user: User
    public let caption: String
    public let imageUrl: String
    public let imageWidth: Float
    public let imageHeight: Float
    public let creationDate: Date
    
    public var hasLiked: Bool
    
    public init(_ id: String, _ user: User, _ caption: String, _ imageUrl: String, _ imageWidth: Float, _ imageHeight: Float, _ creationDate: Double, _ hasLiked: Bool) {
        self.id = id
        self.user = user
        self.caption = caption
        self.imageUrl = imageUrl
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.creationDate = Date(timeIntervalSince1970: creationDate)
        self.hasLiked = hasLiked
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
