//
//  SharePhotoPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

protocol SharePhotoView: ErrorPresentable {
    func displayMain()
}

final class SharePhotoPresenter: SharePhotoUseCaseOutput {
    
    private let view: SharePhotoView
    
    init(view: SharePhotoView) {
        self.view = view
    }
    
    func shareSucceeded() {
        view.displayMain()
    }
    
    func shareFailed(_ error: Error) {
        view.displayError(error.localizedDescription)
    }
}

extension WeakRef: SharePhotoView where T: SharePhotoView {
    func displayMain() {
        object?.displayMain()
    }
}
