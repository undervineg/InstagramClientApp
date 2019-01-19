//
//  CacheManager.swift
//  InstagramClientApp
//
//  Created by 심승민 on 19/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import InstagramEngine

protocol Cacheable {
    func cache(_ data: Data, with key: String)
    func getCachedData(key: String) -> Data?
}

final class CacheManager: Cacheable {
    private var dataCache = [String: Data]()
    
    func cache(_ data: Data, with key: String) {
        dataCache[key] = data
    }
    
    func getCachedData(key: String) -> Data? {
        return dataCache[key]
    }
}
