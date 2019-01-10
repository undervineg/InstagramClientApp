//
//  UserProfileUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 06/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol UserProfileClient {
    func loadCurrentUserInfo(_ completion: @escaping (Result<UserEntity, UserProfileUseCase.Error>) -> Void)
}

public protocol UserProfileUseCaseOutput {
    func loadUserSucceeded(_ user: UserEntity)
    func loadUserFailed(_ error: UserProfileUseCase.Error)
}

final public class UserProfileUseCase {
    
    private let client: UserProfileClient
    private let output: UserProfileUseCaseOutput
    
    public init(client: UserProfileClient, output: UserProfileUseCaseOutput) {
        self.client = client
        self.output = output
    }
    
    public enum Error: Swift.Error {
        case currentUserIDNotExist
        case currentUserNotExist
    }
    
    public func loadProfile() {
        client.loadCurrentUserInfo() { [weak self] result in
            switch result {
            case .success(let user):
                self?.output.loadUserSucceeded(user)
            case .failure(let error):
                self?.output.loadUserFailed(error)
            }
        }
    }
}
