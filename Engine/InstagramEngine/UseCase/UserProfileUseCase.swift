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
    func loadUserInfo(of uid: String, _ completion: @escaping (Result<User, UserProfileUseCase.Error>) -> Void)
    func downloadProfileImage(from url: URL, completion: @escaping (Result<Data, UserProfileUseCase.Error>) -> Void)
    func logout(_ completion: @escaping (Error?) -> Void)
    func fetchAllUsers(shouldOmitCurrentUser: Bool, _ completion: @escaping (Result<[User], Error>) -> Void)
    func followUser(_ uid: String, _ completion: @escaping (UserProfileUseCase.Error?) -> Void)
    func unfollowUser(_ uid: String, _ completion: @escaping (UserProfileUseCase.Error?) -> Void)
    func checkIsFollowing(_ uid: String, _ completion: @escaping (Result<Bool, Error>) -> Void)
    func fetchFollowingListOfCurrentUser(_ completion: @escaping (Result<[String], Error>) -> Void)
    func fetchFollowingList(of uid: String, _ completion: @escaping (Result<[String], Error>) -> Void)
}

public protocol UserProfileUseCaseOutput {
    func loadUserSucceeded(_ user: User)
    func loadUserFailed(_ error: UserProfileUseCase.Error)
    func downloadProfileImageFailed(_ error: UserProfileUseCase.Error)
    func logoutSucceeded()
    func logoutFailed(_ error: UserProfileUseCase.Error)
    func followOrUnfollowUserSucceeeded(_ isFollowing: Bool)
    func followOrUnfollowUserFailed(_ error: UserProfileUseCase.Error)
    func checkIsFollowSucceeded(_ isFollowing: Bool)
    func checkIsFollowFailed(_ error: Error)
}

final public class UserProfileUseCase: FeaturePostLoadable {
    private let client: UserProfileClient
    private let output: UserProfileUseCaseOutput
    
    public let postClient: LoadPostClient
    public let profileClient: UserProfileClient
    public let postOutput: LoadPostOutput
    
    public init(client: UserProfileClient, output: UserProfileUseCaseOutput&LoadPostOutput,
                postClient: LoadPostClient, profileClient: UserProfileClient) {
        self.client = client
        self.output = output
        
        self.postClient = postClient
        self.profileClient = profileClient
        self.postOutput = output
    }
    
    public enum Order {
        case username(Sort)
        case caption(Sort)
    }
    
    public enum Error: Swift.Error {
        case currentUserIDNotExist
        case currentUserNotExist
        case profileImageNotExist
        case logoutError
        case followError
        case unfollowError
        
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
            case .followError:
                return "팔로우 도중 문제가 발생했습니다."
            case .unfollowError:
                return "언팔로우 도중 문제가 발생했습니다."
            }
        }
    }
    
    public func loadProfile(of uid: String?) {
        if let uid = uid {
            client.loadUserInfo(of: uid, handleLoadedResult)
        } else {
            client.loadCurrentUserInfo(handleLoadedResult)
        }
    }
    
    private func handleLoadedResult(_ result: Result<User, UserProfileUseCase.Error>) {
        switch result {
        case .success(let user):
            output.loadUserSucceeded(user)
        case .failure(let error):
            output.loadUserFailed(error)
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
    
    public func followUser(_ uid: String) {
        client.followUser(uid) { [weak self] (error) in
            if let error = error {
                self?.output.followOrUnfollowUserFailed(error)
                return
            }
            self?.output.followOrUnfollowUserSucceeeded(true)
            NotificationCenter.default.post(name: NotificationName.followNewUser, object: nil)
        }
    }
    
    public func unfollowUser(_ uid: String) {
        client.unfollowUser(uid) { [weak self] (error) in
            if let error = error {
                self?.output.followOrUnfollowUserFailed(error)
                return
            }
            self?.output.followOrUnfollowUserSucceeeded(false)
            NotificationCenter.default.post(name: NotificationName.unfollowOldUser, object: nil)
        }
    }
    
    public func checkIsFollowing(_ uid: String) {
        client.checkIsFollowing(uid) { [weak self] (result) in
            switch result {
            case .success(let isFollowing):
                self?.output.checkIsFollowSucceeded(isFollowing)
            case .failure(let error):
                self?.output.checkIsFollowFailed(error)
            }
        }
    }
}
