//
//  SearchUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 20/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol SearchUseCaseOutput {
    func fetchAllUserSucceeded(_ users: [User])
    func fetchAllUserFailed(_ error: Error)
}

final public class SearchUseCase {
    private let client: UserProfileClient
    private let output: SearchUseCaseOutput
    
    public init(client: UserProfileClient, output: SearchUseCaseOutput) {
        self.client = client
        self.output = output
    }
    
    public func fetchAllUsers(shouldOmitCurrentUser: Bool) {
        client.fetchAllUsers(shouldOmitCurrentUser: shouldOmitCurrentUser) { [weak self] (result) in
            switch result {
            case .success(let users):
                self?.output.fetchAllUserSucceeded(users)
            case .failure(let error):
                self?.output.fetchAllUserFailed(error)
            }
        }
    }
}
