//
//  PhotoSelectorPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import InstagramEngine

protocol PhotoSelectorView: ErrorPresentable {
    func displayAllPhotos(_ data: Data)
}

final class PhotoSelectorPresenter: LoadPhotoUseCaseOutput {
    
    private let view: PhotoSelectorView
    
    init(view: PhotoSelectorView) {
        self.view = view
    }
    
    func fetchAllPhotosSucceeded(_ photoData: Data) {
        view.displayAllPhotos(photoData)
    }
    
    func fetchAllPhotosFailed(_ error: LoadPhotoUseCase.Error) {
        view.displayError(error.localizedDescription)
    }
}

extension WeakRef: PhotoSelectorView where T: PhotoSelectorView {
    func displayAllPhotos(_ data: Data) {
        object?.displayAllPhotos(data)
    }
}
