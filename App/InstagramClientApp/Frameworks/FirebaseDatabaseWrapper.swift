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
    static func fetchAll<T>(under refs: [Reference], completion: @escaping (Result<T?, Error>) -> Void)
    static func fetchNew<T>(under refs: [Reference], orderBy order: HasKey, completion: @escaping (Result<(String, T), Error>) -> Void)
    static func fetchUpdated<T>(under refs: [Reference], orderBy order: HasKey, completion: @escaping (Result<(String, T), Error>) -> Void)
    static func fetchDeleted<T>(under refs: [Reference], orderBy order: HasKey, completion: @escaping (Result<(String, T), Error>) -> Void)
    static func fetch<T>(under refs: [Reference], from startValue: Any?, to limit: Int, orderBy order: HasKey&Sortable, completion: @escaping (Result<([(String, T)], Bool), Error>) -> Void)
    static func delete(from refs: [Reference], completion: @escaping (Error?) -> Void)
}

extension Database: FirebaseDatabaseWrapper {
    
    static func update(_ values: [AnyHashable: Any], under refs: [Reference], completion: @escaping (Error?) -> Void) {
        guard let newRef = databaseReference(from: refs) else { return }
        newRef.updateChildValues(values) { (error, _) in completion(error) }
    }
    
    static func fetchAll<T>(under refs: [Reference], completion: @escaping (Result<T?, Error>) -> Void) {
        let newRef = databaseReference(from: refs)
        
        // Fetch all childs of newRef at once
        newRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            let values = snapshot.value as? T
            completion(.success(values))
        }) { (error) in
            completion(.failure(error))
        }
    }
    
    static func fetchNew<T>(under refs: [Reference], orderBy order: HasKey, completion: @escaping (Result<(String, T), Error>) -> Void) {
        fetch(.childAdded, refs, order, completion)
    }
    
    static func fetchUpdated<T>(under refs: [Reference], orderBy order: HasKey, completion: @escaping (Result<(String, T), Error>) -> Void) {
        fetch(.childChanged, refs, order, completion)
    }
    
    static func fetchDeleted<T>(under refs: [Reference], orderBy order: HasKey, completion: @escaping (Result<(String, T), Error>) -> Void) {
        fetch(.childRemoved, refs, order, completion)
    }
    
    static func fetch<T>(under refs: [Reference], from fromValue: Any?, to limit: Int, orderBy order: HasKey&Sortable, completion: @escaping (Result<([(String, T)], Bool), Error>) -> Void) {
        guard let newRef = databaseReference(from: refs) else { return }

        var query = newRef.queryOrdered(byChild: order.key)

        switch order.sortBy {
        case .ascending:
            if let startValue = fromValue {
                query = query.queryStarting(atValue: startValue)
            }
            query = query.queryLimited(toFirst: UInt(limit))
        case .descending:
            if let endValue = fromValue {
                query = query.queryEnding(atValue: endValue)
            }
            query = query.queryLimited(toLast: UInt(limit))
        }

        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard var childSnapshots = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            childSnapshots.forEach({ print("raw: ", $0.key) })
            
            if order.sortBy == .descending {
                childSnapshots.reverse()
            }
            
            let isPagingFinished = childSnapshots.count < limit
            
            if fromValue != nil && childSnapshots.count > 0 {
                childSnapshots.removeFirst()
            }

            let parsedValues = childSnapshots.compactMap({ (childSnapshot) -> (String, T)? in
                guard let value = childSnapshot.value as? T else {
                    print("Casting nil error at: ", #function)
                    return nil
                }
                print("preprocessed: ", childSnapshot.key)
                return (childSnapshot.key, value)
            })
            completion(.success((parsedValues, isPagingFinished)))

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
    
    // MARK: Private Methods
    private static func fetch<T>(_ eventType: DataEventType, _ refs: [Reference], _ order: HasKey, _ completion: @escaping (Result<(String, T), Error>) -> Void) {
        guard let newRef = databaseReference(from: refs) else { return }
        
        newRef.queryOrdered(byChild: order.key).observe(eventType, with: { (snapshot) in
            guard let value = snapshot.value as? T else { return }
            completion(.success((snapshot.key, value)))
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
