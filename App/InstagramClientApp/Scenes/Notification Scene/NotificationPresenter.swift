//
//  NotificationPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 21/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

protocol NotificationView: ErrorPresentable {
    func displayNotification(_ notification: PushNotification)
}

final class NotificationPresenter: NotificationOutput {
    
    private let view: NotificationView
    
    init(view: NotificationView) {
        self.view = view
    }
    
    func loadNotificationsSucceed(_ notification: PushNotification) {
        view.displayNotification(notification)
    }
    
    func loadNotificationsFailed(_ error: Error) {
        
    }
}

extension WeakRef: NotificationView where T: NotificationView {
    func displayNotification(_ notification: PushNotification) {
        object?.displayNotification(notification)
    }
}
