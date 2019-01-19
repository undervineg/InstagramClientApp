//
//  Sort.swift
//  InstagramClientApp
//
//  Created by 심승민 on 18/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

protocol HasKey {
    var key: String { get }
}

protocol Sortable {
    var sortBy: Sort { get }
}
