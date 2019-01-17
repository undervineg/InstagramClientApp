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
    func fetchPosts(_ completion: @escaping (Result<[Post], UserProfileUseCase.Error>) -> Void)
    func downloadPostImage(from url: URL, completion: @escaping (Result<Data, UserProfileUseCase.Error>) -> Void)
}

public protocol UserProfileUseCaseOutput {
    func loadUserSucceeded(_ user: User)
    func loadUserFailed(_ error: UserProfileUseCase.Error)
    func downloadProfileImageFailed(_ error: UserProfileUseCase.Error)
    func logoutSucceeded()
    func logoutFailed(_ error: UserProfileUseCase.Error)
    func loadPostsSucceeded(_ posts: [Post])
    func loadPostsFailed(_ error: UserProfileUseCase.Error)
    func downloadPostImageFailed(_ error: UserProfileUseCase.Error)
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
        case postsNotExist
        case postImageNotFound
        
        public var localizedDescription: String {
            switch self {
            case .currentUserIDNotExist:
                return "사용자 계정이 없습니다."
            case .currentUserNotExist:
                return "사용자 정보가 없습니다."
            case .profileImageNotExist:
                return "프로필 이미지를 불러올 수 없습니다."
            case .logoutError:
                return "로그아웃 도중 문제가 발생했습니다."
            case .postsNotExist:
                return "사용자의 게시물이 존재하지 않습니다."
            case .postImageNotFound:
                return "일부 게시글의 이미지를 불러올 수 없습니다."
            }
        }
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
    
    public func downloadProfileImage(from url: URL, completion: @escaping (Data) -> Void) {
        client.downloadProfileImage(from: url) { [weak self] (result) in
            switch result {
            case .success(let data):
                completion(data)
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
    
    public func loadPosts() {
        client.fetchPosts { [weak self] (result) in
            switch result {
            case .success(let posts):
                self?.output.loadPostsSucceeded(posts)
            case .failure(let error):
                self?.output.loadPostsFailed(error)
            }
        }
    }
    
    public func downloadPostImage(from url: URL, completion: @escaping (Data) -> Void) {
        client.downloadPostImage(from: url) { [weak self] (result) in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                self?.output.downloadPostImageFailed(error)
            }
        }
    }
}
