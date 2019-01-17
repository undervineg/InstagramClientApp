//
//  FirebaseDatabaseWrapper.swift
//  InstagramClientApp
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseDatabase
import InstagramEngine

protocol FirebaseDatabaseWrapper {
    static func update(_ values: [AnyHashable: Any], to refs: [Reference], completion: @escaping (Error?) -> Void)
    static func fetch(from refs: [Reference], completion: @escaping (Result<[String: Any], Error>) -> Void)
}

extension Database: FirebaseDatabaseWrapper {
    
    static func update(_ values: [AnyHashable: Any], to refs: [Reference], completion: @escaping (Error?) -> Void) {
        guard let newRef = databaseReference(from: refs) else { return }
        newRef.updateChildValues(values) { (error, _) in completion(error) }
    }
    
    static func fetch(from refs: [Reference], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let newRef = databaseReference(from: refs) else { return }
        
        newRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let values = snapshot.value as? [String: Any] else {
                let error = NSError(domain: "Value casting error", code: 0)
                completion(.failure(error))
                return
            }
            completion(.success(values))
        }) { (error) in
            completion(.failure(error))
        }
    }
}

extension Database {
    // MARK: Private Methods
    private static func databaseReference(from childRefs: [Reference]) -> DatabaseReference? {
        let rootRef = database().reference()
        return rootRef.reference(by: childRefs) as? DatabaseReference
    }
}

extension DatabaseReference: FirebaseReferenceType {
    func child(by reference: Reference) -> FirebaseReferenceType {
        switch reference {
        case .directory(let name): return child(name)
        case .autoId: return childByAutoId()
        default: return self
        }
    }
}
