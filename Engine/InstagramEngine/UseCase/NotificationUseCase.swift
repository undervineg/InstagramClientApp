//
//  NotificationUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 21/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol NotificationClient {
    func fetchAllNotifications(of uid: String?, _ completion: @escaping (Result<PushNotification, Error>) -> Void)
    func readAllNotifications(of uid: String?, _ completion: @escaping (Error?) -> Void)
    func readNotification(of uid: String?, at notificationId: String, _ completion: @escaping (Error?) -> Void)
}

public protocol NotificationOutput {
    func loadNotificationsSucceed(_ notification: PushNotification)
    func loadNotificationsFailed(_ error: Error)
}

final public class NotificationUseCase {
    private let client: NotificationClient
    private let output: NotificationOutput
    
    public init(client: NotificationClient, output: NotificationOutput) {
        self.client = client
        self.output = output
    }
    
    public func loadAllNotifications(of uid: String?) {
        client.fetchAllNotifications(of: uid) { [weak self] (result) in
            switch result {
            case .success(let notification):
                self?.output.loadNotificationsSucceed(notification)
            case .failure(let error):
                self?.output.loadNotificationsFailed(error)
            }
        }
    }
    
    public func readAllNotifications(of uid: String?) {
        
    }
    
    public func readNotification(of uid: String?, at notificationId: String) {
        
    }
}
