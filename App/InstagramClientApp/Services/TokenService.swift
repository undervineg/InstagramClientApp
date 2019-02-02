//
//  TokenService.swift
//  InstagramClientApp
//
//  Created by 심승민 on 02/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

final class TokenService {
    private let auth: FirebaseAuthWrapper.Type
    private let database: FirebaseDatabaseWrapper.Type
    
    init(auth: FirebaseAuthWrapper.Type,
         database: FirebaseDatabaseWrapper.Type) {
        self.auth = auth
        self.database = database
    }
    
    private var newFcmToken: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.UserDefaults.fcmToken)
        }
        get {
            return UserDefaults.standard.string(forKey: Keys.UserDefaults.fcmToken)
        }
    }
    
    func refreshFcmToken() {
        guard let newFcmToken = self.newFcmToken else { return }
        refreshFcmToken(with: newFcmToken)
    }
    
    func refreshFcmToken(with newFcmToken: String) {
        self.newFcmToken = newFcmToken
        
        guard let uid = auth.currentUserId else { return }
        updateUserFcmToken(uid, fcmToken: newFcmToken)
        
        print("New FCM token registered: ", newFcmToken)
    }
    
    func invalidateFcmToken() {
        guard let uid = auth.currentUserId else { return }
        removeUserFcmToken(from: uid)
        
        print("Removed \(uid)'s FCM token")
    }
    
    // MARK: Private Methods
    private func updateUserFcmToken(_ uid: String, fcmToken: String) {
        let values = [Keys.Database.Profile.fcmToken: fcmToken]
        let refs = [Reference.directory(Keys.Database.usersDir), .directory(uid)]
        database.update(values, under: refs) { (error) in
            if let error = error {
                print("Error occur on refreshing fcm token: ", error)
            }
        }
    }
    
    private func removeUserFcmToken(from uid: String) {
        let refs = [Reference.directory(Keys.Database.usersDir), .directory(uid), .directory(Keys.Database.Profile.fcmToken)]
        database.delete(from: refs) { (error) in
            if let error = error {
                print("Error occur on removing fcm token: ", error)
            }
        }
    }
}
