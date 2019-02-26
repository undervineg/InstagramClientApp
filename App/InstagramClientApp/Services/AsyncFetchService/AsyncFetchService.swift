//
//  AsyncFetchService.swift
//  InstagramClientApp
//
//  Created by 심승민 on 14/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

class CustomOperation<ID: AnyObject, MODELTYPE, DATATYPE: AnyObject>: Operation {
    let identifier: ID
    let model: MODELTYPE
    
    var networking: APIClient?
    var fetchedData: DATATYPE?
    
    required init(identifier: ID, model: MODELTYPE) {
        self.identifier = identifier
        self.model = model
    }
}

final class AsyncFetchService<ID: AnyObject&Hashable, MODELTYPE, DATATYPE: AnyObject> {
    // MARK: Properties
    private let serialAccessQueue = OperationQueue()
    private let fetchQueue = OperationQueue()
    private var completionHandlers = [ID: [(DATATYPE?) -> Void]]()
    private var cache = NSCache<ID, DATATYPE>()
    private let networking: APIClient?
    
    private let operationType: CustomOperation<ID, MODELTYPE, DATATYPE>.Type
    
    // MARK: Methods
    init(operationType: CustomOperation<ID, MODELTYPE, DATATYPE>.Type, networking: APIClient? = nil) {
        self.operationType = operationType
        self.networking = networking
        serialAccessQueue.maxConcurrentOperationCount = 1
    }
    
    func startFetch(_ identifier: ID, _ model: MODELTYPE, completion: ((DATATYPE?) -> Void)? = nil) {
        serialAccessQueue.addOperation {
            if let completion = completion {
                let handlers = self.completionHandlers[identifier, default: []]
                self.completionHandlers[identifier] = handlers + [completion]
            }
            
            self.fetchData(for: identifier, with: model)
        }
    }
    
    func fetchedData(for identifier: ID) -> DATATYPE? {
        return cache.object(forKey: identifier)
    }
    
    func cancelFetch(_ identifier: ID) {
        serialAccessQueue.addOperation {
            self.fetchQueue.isSuspended = true
            defer { self.fetchQueue.isSuspended = false }
            
            self.operation(for: identifier)?.cancel()
            self.completionHandlers[identifier] = nil
        }
    }
    
    // MARK: Private Methods
    private func fetchData(for identifier: ID, with model: MODELTYPE) {
        guard operation(for: identifier) == nil else { return }
        
        if let cachedData = fetchedData(for: identifier) {
            invokeCompletion(for: identifier, with: cachedData)
        } else {
            let operation = operationType.init(identifier: identifier, model: model)
            operation.networking = networking
            operation.completionBlock = { [weak operation] in
                guard let fetchedData = operation?.fetchedData else { return }
                self.cache.setObject(fetchedData, forKey: identifier)
                
                self.serialAccessQueue.addOperation {
                    self.invokeCompletion(for: identifier, with: fetchedData)
                }
            }
            fetchQueue.addOperation(operation)
        }
    }
    
    private func operation(for identifier: ID) -> CustomOperation<ID, MODELTYPE, DATATYPE>? {
        for case let fetchOperation as CustomOperation<ID, MODELTYPE, DATATYPE> in fetchQueue.operations
            where !fetchOperation.isCancelled && fetchOperation.identifier == identifier {
            return fetchOperation
        }
        return nil
    }
    
    private func invokeCompletion(for identifier: ID, with fetchedData: DATATYPE?) {
        let completionBlocks = completionHandlers[identifier, default: []]
        completionHandlers[identifier] = nil
        
        completionBlocks.forEach { $0(fetchedData) }
    }
}
