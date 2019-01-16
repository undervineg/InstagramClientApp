//
//  Post.swift
//  InstagramEngine
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public struct Post {
    public let caption: String
    public let imageUrl: String?
    public let imageWidth: Float
    public let imageHeight: Float
    public let creationDate: Double
    
    public init(_ caption: String, _ imageUrl: String?, _ imageWidth: Float, _ imageHeight: Float, _ creationDate: Double) {
        self.caption = caption
        self.imageUrl = imageUrl
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.creationDate = creationDate
    }
}
