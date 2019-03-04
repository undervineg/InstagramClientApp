//
//  AppDelegate.swift
//  InstagramClientApp
//
//  Created by 심승민 on 31/12/2018.
//  Copyright © 2018 심승민. All rights reserved.
//

import UIKit
import Firebase
import InstagramEngine
import UserNotifications

//@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        attemptRegisterForRemoteNotifications(application)

        let window = UIWindow(frame: UIScreen.main.bounds)
        let splashModule = SplashModule()
        splashModule.router.openLoginCallback = { mainVC in
            window.rootViewController = mainVC
        }
        splashModule.router.openMainCallback = { loginVC in
            window.rootViewController = loginVC
        }
        
        window.rootViewController = splashModule.viewController
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        
        self.window = window
        
        UITabBar.appearance().tintColor = .black
        
        return true
    }
    
    private func attemptRegisterForRemoteNotifications(_ application: UIApplication) {
        // FCM token and message delegate
        Messaging.messaging().delegate = self
        
        // UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = self
        
        // user authorization
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if let error = error {
                print("Failed to request auth: ", error)
                return
            }
            if granted {
                print("Succeeded to user auth granted: Register for remote notification")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("User denied to receive notification")
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let tokenService = TokenService(auth: Auth.self, database: Database.self)
        tokenService.refreshFcmToken(with: fcmToken)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Handle user actions to notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        handlePushNotification(userInfo)
        
        completionHandler()
    }
    
    // Just alert when it's foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    // MARK: Private Methods
    private func handlePushNotification(_ userInfo: [AnyHashable : Any]) {
        guard
            let notificationTag = (userInfo["type"] as? NSString)?.integerValue,
            let notificationType = PushNotificationType(rawValue: notificationTag) else {
                return
        }
        
        switch notificationType {
        case .myNews:
            guard let followerId = userInfo["followerId"] as? String else { break }
            openFollowerPage(id: followerId)
        case .followingNews:
            guard let postId = userInfo["postId"] as? String else { return }
            openPostPage(id: postId)
        }
    }
    
    private func openFollowerPage(id followerId: String) {
        if window?.rootViewController is SplashViewController {
            openFollowerPageFromMain(followerId: followerId, after: 5000)
        } else {
            openFollowerPageFromMain(followerId: followerId)
        }
    }
    
    private func openPostPage(id postId: String) {
        // TODO: Make Post page and route.
    }
    
    private func openFollowerPageFromMain(followerId: String, after nanoSeconds: UInt64 = 0) {
        DispatchQueue.main.asyncAfter(deadline: .init(uptimeNanoseconds: nanoSeconds)) {
            guard let currentViewController = self.window?.rootViewController as? MainTabBarViewController else {
                return
            }
            
            currentViewController.presentedViewController?.dismiss(animated: true, completion: nil)
            
            let currentTabIndex = currentViewController.selectedIndex
            let currentTabVC = currentViewController.viewControllers?[currentTabIndex]
            
            let router = PushRouter()
            router.viewController = currentTabVC
            router.openUserProfilePage(of: followerId)
        }
    }
}
