//
//  AuthUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol AuthClient {
    func checkIfAuthenticated(_ completion: @escaping (Bool) -> Void)
}

public protocol AuthUseCaseOutput {
    func authSucceeded()
    func authFailed()
}

final public class AuthUseCase {
    private let client: AuthClient
    private let output: AuthUseCaseOutput
    
    public init(client: AuthClient, output: AuthUseCaseOutput) {
        self.client = client
        self.output = output
    }
    
    public func checkIfAuthenticated() {
        client.checkIfAuthenticated { [weak self] (isAuthenticated) in
            if isAuthenticated {
                self?.output.authSucceeded()
            } else {
                self?.output.authFailed()
            }
        }
    }
}
