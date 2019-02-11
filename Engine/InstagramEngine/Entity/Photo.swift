//
//  Photo.swift
//  InstagramEngine
//
//  Created by 심승민 on 29/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public struct Photo {
    public enum Order {
        case creationDate(Sort)
    }
}

public struct PhotoAsset {
    public let identifier: String
    public let isLivePhoto: Bool
    
    public init(identifier: String, isLivePhoto: Bool) {
        self.identifier = identifier
        self.isLivePhoto = isLivePhoto
    }
}
