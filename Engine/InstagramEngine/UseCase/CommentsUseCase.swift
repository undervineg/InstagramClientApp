//
//  CommentsUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 25/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol CommentsClient {
    func saveComment(_ commentText: String, _ submitDate: Double, forPost postId: String, _ completion: @escaping (Error?) -> Void)
    func fetchComments(postId: String, with order: Comment.Order, _ completion: @escaping (Result<Comment, Error>) -> Void)
}

public protocol CommentsUseCaseOutput {
    func saveCommentFailed(_ error: CommentsUseCase.Error)
    func fetchCommentSucceeded(_ comment: Comment)
    func fetchCommentFailed(_ error: CommentsUseCase.Error)
}

final public class CommentsUseCase {
    private let client: CommentsClient
    private let output: CommentsUseCaseOutput
    
    public init(client: CommentsClient, output: CommentsUseCaseOutput) {
        self.client = client
        self.output = output
    }
    
    public enum Error: Swift.Error {
        case saveCommentError
        case fetchCommentsError
        
        var localizedDescription: String {
            switch self {
            case .saveCommentError: return "댓글 저장 중 문제가 발생했습니다. 다시 시도해주세요."
            case .fetchCommentsError: return "댓글을 불러오는 도중 문제가 발생했습니다. 다시 시도해주세요."
            }
        }
    }
    
    public func saveComment(_ commentText: String, _ submitDate: Double, forPost postId: String) {
        client.saveComment(commentText, submitDate, forPost: postId) { [weak self] (error) in
            if error != nil {
                self?.output.saveCommentFailed(.saveCommentError)
            }
        }
    }
    
    public func loadComments(of postId: String, inOrder order: Comment.Order) {
        client.fetchComments(postId: postId, with: order) { [weak self] (result) in
            switch result {
            case .success(let comment):
                self?.output.fetchCommentSucceeded(comment)
            case .failure:
                self?.output.fetchCommentFailed(.fetchCommentsError)
            }
        }
    }
}
