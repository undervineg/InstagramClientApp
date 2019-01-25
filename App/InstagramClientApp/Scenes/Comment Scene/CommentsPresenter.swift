//
//  CommentsPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 25/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

protocol CommentsView: ErrorPresentable {
    func displayComment(_ comment: Comment)
}

final class CommentsPresenter: CommentsUseCaseOutput {
    private let view: CommentsView
    
    init(view: CommentsView) {
        self.view = view
    }
    
    func saveCommentFailed(_ error: CommentsUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
    
    func fetchCommentSucceeded(_ comment: Comment) {
        view.displayComment(comment)
    }
    
    func fetchCommentFailed(_ error: CommentsUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
}

extension WeakRef: CommentsView where T: CommentsView {
    func displayComment(_ comment: Comment) {
        object?.displayComment(comment)
    }
}
