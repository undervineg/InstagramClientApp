//
//  Reference.swift
//  InstagramClientApp
//
//  Created by 심승민 on 17/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseDatabase

protocol FirebaseReferenceType {
    func child(by reference: Reference) -> FirebaseReferenceType
    func reference(by childRefs: [Reference]) -> FirebaseReferenceType?
}

extension FirebaseReferenceType {
    func reference(by childRefs: [Reference]) -> FirebaseReferenceType? {
        var resultRef: Reference = Reference.value(self)
        childRefs.forEach {
            resultRef = resultRef.child(by: $0)
        }
        
        switch resultRef {
        case .value(let firebaseRef): return firebaseRef
        default:  return nil
        }
    }
}

enum Reference {
    case value(FirebaseReferenceType)
    case directory(String)
    case autoId
    
    func child(by ref: Reference) -> Reference {
        switch ref {
        case .value: return self
        case .directory(let name):
            if case let Reference.value(parent) = self {
                return Reference.value(parent.child(by: .directory(name)))
            }
        case .autoId:
            if case let Reference.value(parent) = self {
                return Reference.value(parent.child(by: .autoId))
            }
        }
        return self
    }
}
