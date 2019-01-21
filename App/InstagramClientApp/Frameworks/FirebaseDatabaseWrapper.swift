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
    static func update(_ values: [AnyHashable: Any], under refs: [Reference], completion: @escaping (Error?) -> Void)
    static func fetchAll<T>(under refs: [Reference], completion: @escaping (Result<T, Error>) -> Void)
    static func fetch<T>(under refs: [Reference], orderBy order: HasKey & Sortable, completion: @escaping (Result<T, Error>) -> Void)
    static func delete(from refs: [Reference], completion: @escaping (Error?) -> Void)
}

extension Database: FirebaseDatabaseWrapper {
    
    static func update(_ values: [AnyHashable: Any], under refs: [Reference], completion: @escaping (Error?) -> Void) {
        guard let newRef = databaseReference(from: refs) else { return }
        newRef.updateChildValues(values) { (error, _) in completion(error) }
    }
    
    static func fetchAll<T>(under refs: [Reference], completion: @escaping (Result<T, Error>) -> Void) {
        guard let newRef = databaseReference(from: refs) else { return }
        
        // Fetch all childs of newRef at once
        newRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let values = snapshot.value as? T else { return }
            completion(.success(values))
        }) { (error) in
            completion(.failure(error))
        }
    }
    
    static func fetch<T>(under refs: [Reference], orderBy order: HasKey & Sortable, completion: @escaping (Result<T, Error>) -> Void) {
        guard let newRef = databaseReference(from: refs) else { return }
        
        // Fetch 1 by 1
        newRef.queryOrdered(byChild: order.key).observe(.childAdded, with: { (snapshot) in
            guard let value = snapshot.value as? T else { return }
            completion(.success(value))
        }) { (error) in
            completion(.failure(error))
        }
    }
    
    static func delete(from refs: [Reference], completion: @escaping (Error?) -> Void) {
        guard let newRef = databaseReference(from: refs) else { return }
        
        newRef.removeValue { (error, ref) in
            completion(error)
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
