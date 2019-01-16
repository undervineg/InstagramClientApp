//
//  UserProfileUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 06/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol UserProfileClient {
    func loadCurrentUserInfo(_ completion: @escaping (Result<User, UserProfileUseCase.Error>) -> Void)
    func downloadProfileImage(from url: URL, completion: @escaping (Result<Data, UserProfileUseCase.Error>) -> Void)
    func logout(_ completion: @escaping (Error?) -> Void)
}

public protocol UserProfileUseCaseOutput {
    func loadUserSucceeded(_ user: User)
    func loadUserFailed(_ error: UserProfileUseCase.Error)
    func downloadProfileImageSucceeded(_ imageData: Data)
    func downloadProfileImageFailed(_ error: UserProfileUseCase.Error)
    func logoutSucceeded()
    func logoutFailed(_ error: UserProfileUseCase.Error)
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
        case profileImageNotExist
        case logoutError
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
    
    public func downloadProfileImage(from url: URL) {
        client.downloadProfileImage(from: url) { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.output.downloadProfileImageSucceeded(data)
            case .failure(let error):
                self?.output.downloadProfileImageFailed(error)
            }
        }
    }
    
    public func logout() {
        client.logout { [weak self] (error) in
            if let _ = error {
                self?.output.logoutFailed(.logoutError)
            }
            self?.output.logoutSucceeded()
        }
    }
}
