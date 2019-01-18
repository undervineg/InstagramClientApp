//
//  FirebaseStorageWrapper.swift
//  InstagramClientApp
//
//  Created by 심승민 on 03/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseStorage
import InstagramEngine

protocol FirebaseStorageWrapper {
    static func uploadImage(_ imageData: Data, to refs: [Reference], completion: @escaping (Result<String, Error>) -> Void)
}

extension Storage: FirebaseStorageWrapper {
    static func uploadImage(_ imageData: Data, to refs: [Reference], completion: @escaping (Result<String, Error>) -> Void) {
        let ref = stoargeReference(from: refs)
        
        ref?.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            }
            ref?.downloadURL(completion: { (url, error) in
                if let error = error {
                    completion(.failure(error))
                }
                guard let url = url else {
                    let noURLError = NSError(domain: "Download URL Not Exist", code: 0)
                    completion(.failure(noURLError))
                    return
                }
                completion(.success(url.absoluteString))
            })
        })
    }
}

extension Storage {
    // MARK: Private Methods
    private static func stoargeReference(from childRefs: [Reference]) -> StorageReference? {
        let rootRef = storage().reference()
        return rootRef.reference(by: childRefs) as? StorageReference
    }
}

extension StorageReference: FirebaseReferenceType {
    func child(by reference: Reference) -> FirebaseReferenceType {
        switch reference {
        case .directory(let name): return self.child(name)
        default: return self
        }
    }
}
