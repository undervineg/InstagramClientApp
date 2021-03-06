//
//  Result.swift
//  InstagramEngine
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public enum Result<T, E> {
    case success(T)
    case failure(E)
}
