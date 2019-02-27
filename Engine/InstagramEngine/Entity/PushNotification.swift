//
//  PushNotification.swift
//  InstagramEngine
//
//  Created by 심승민 on 21/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public enum ReadState {
    case read
    case unread
}

public final class PushNotificationObject {
    public let uuid: UUID
    public var data: PushNotification
    
    public init(_ data: PushNotification) {
        self.uuid = UUID()
        self.data = data
    }
}

public enum PushNotificationType: Int {
    case myNews = 0
    case followingNews
}

public enum PushNotificationButtonType: Int {
    case follow = 0
}

public struct PushNotification {
    public let id: String
    public let type: PushNotificationType
    public let title: String?
    public let body: String
    public let emphasizeIndices: [Int]?
    public let creationDate: Date
    public let profileImageUrl: String
    public let profileLink: String
    public let detailImageUrls: [String]?
    public let detailLinks: [String]?
    public let detailButtonType: PushNotificationButtonType?
    
    public private(set) var readState: ReadState = .unread
    private var readDateInterval: Double? { didSet { self.readState = .read } }
    
    public init(_ id: String,
                _ type: Int,
                _ title: String?=nil,
                _ body: String,
                _ emphasizeIndices: [Int]?=nil,
                _ creationDate: Double,
                _ readDate: Double?=nil,
                _ profileImageUrl: String,
                _ profileLink: String,
                _ detailImageUrls: [String]?=nil,
                _ detailLinks: [String]?=nil,
                _ detailButtonType: Int?=nil) {
        self.id = id
        self.type = PushNotificationType(rawValue: type) ?? .myNews
        self.title = title
        self.body = body
        self.creationDate = Date(timeIntervalSince1970: creationDate)
        self.readDateInterval = readDate
        self.emphasizeIndices = emphasizeIndices
        self.profileImageUrl = profileImageUrl
        self.profileLink = profileLink
        self.detailImageUrls = detailImageUrls
        self.detailLinks = detailLinks
        self.detailButtonType = (detailButtonType == nil) ? nil : PushNotificationButtonType(rawValue: detailButtonType!)
    }
    
    public enum Order {
        case creationDate(Sort)
    }
}
