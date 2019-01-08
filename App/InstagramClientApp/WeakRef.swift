//
//  WeakRef.swift
//  InstagramClientApp
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import InstagramEngine

class WeakRef<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}
