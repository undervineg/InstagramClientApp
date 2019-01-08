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
    
}

final public class UserProfileUseCase {
    
    private let client: UserProfileClient
    private let output: UserProfileUseCaseOutput
    
    init(client: UserProfileClient, output: UserProfileUseCaseOutput) {
        self.client = client
        self.output = output
    }
    
    public enum Error: Swift.Error {
        case currentUserNotExist
    }
    
    public func loadProfile(_ completion: @escaping (Result<UserEntity, Error>) -> Void) {
        client.loadCurrentUserInfo() { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
