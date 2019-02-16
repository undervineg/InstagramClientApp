//
//  HomeFeedUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 19/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol LikesOutput {
    func changeLikesSucceeded(to newLikesState: Bool, at index: Int)
    func saveLikesFailed(_ error: Error)
}

final public class HomeFeedUseCase: FeaturePostLoadable {
    public let postClient: LoadPostClient
    public let postOutput: LoadPostOutput
    private let likesOutput: LikesOutput
    
    public init(postClient: LoadPostClient, output: LoadPostOutput&LikesOutput) {
        self.postClient = postClient
        self.postOutput = output
        self.likesOutput = output
    }
    
    public enum Error: Swift.Error {
        case userIDNotExist
        case postsNotExist
        case postImageNotFound
        case fetchFollowingListError
        case loadLikesError
        case saveLikesError
        
        public var localizedDescription: String {
            switch self {
            case .userIDNotExist:
                return "일부 사용자 계정을 찾을 수 없습니다."
            case .postsNotExist:
                return "사용자의 게시물이 존재하지 않습니다."
            case .postImageNotFound:
                return "일부 게시글의 이미지를 불러올 수 없습니다."
            case .fetchFollowingListError:
                return "사용자의 팔로우 리스트를 불러오는 데 문제가 발생했습니다."
            case .loadLikesError:
                return "좋아요를 불러오는 도중 문제가 발생했습니다."
            case .saveLikesError:
                return "좋아요 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
            }
        }
    }
    
    public func changeLikes(of postId: String, to newLikesState: Bool, at index: Int) {
        postClient.changeLikes(of: postId, to: newLikesState) { [weak self] (error) in
            if let error = error {
                self?.likesOutput.saveLikesFailed(error)
            }
            self?.likesOutput.changeLikesSucceeded(to: newLikesState, at: index)
        }
    }

}
