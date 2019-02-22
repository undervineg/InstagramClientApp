//
//  PushNotification.swift
//  InstagramEngine
//
//  Created by 심승민 on 21/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public struct PushNotification {
    public let id: String
    public let title: String?
    public let body: String
    public let creationDate: Date
    public private(set) var readDate: Date?
    
    private var readDateInterval: Double? {
        didSet {
            self.readDate = Date(timeIntervalSince1970: readDateInterval ?? 0)
        }
    }
    
    public init(_ id: String, _ title: String?, _ body: String, _ creationDate: Double, _ readDate: Double?) {
        self.id = id
        self.title = title
        self.body = body
        self.creationDate = Date(timeIntervalSince1970: creationDate)
        self.readDateInterval = readDate
    }
    
    public enum Order {
        case creationDate(Sort)
    }
}
