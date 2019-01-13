//
//  FirebaseAuthWrapper.swift
//  InstagramClientApp
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseAuth
import InstagramEngine

protocol FirebaseAuthWrapper {
    static var isAuthenticated: Bool { get }
    static var currentUserId: String? { get }
    
    static func registerUser(email: String, password: String, completion: @escaping (Result<(id: String, email: String?), Error>) -> Void)
    static func login(email: String, password: String, completion: @escaping (Error?) -> Void)
    static func logout(_ completion: (Error?) -> Void)
}

extension Auth: FirebaseAuthWrapper {
    static var isAuthenticated: Bool {
        return auth().currentUser != nil
    }
    
    static var currentUserId: String? {
        return auth().currentUser?.uid
    }
    
    static func registerUser(email: String, password: String, completion: @escaping (Result<(id: String, email: String?), Error>) -> Void) {
        auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
            }
            if let result = result {
                let user = result.user
                completion(.success((user.uid, user.email)))
            }
        }
    }
    
    static func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        auth().signIn(withEmail: email, password: password) { (_, error) in
            completion(error)
        }
    }
    
    static func logout(_ completion: (Error?) -> Void) {
        do {
            try auth().signOut()
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
