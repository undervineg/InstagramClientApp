//
//  PhotoSelectorPresenter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import InstagramEngine
import UIKit

//protocol PhotoSelectorView: ErrorPresentable {
//    func displayImage(at index: Int, image: UIImage?)
//
//    func preparePhotoCells(of count: Int)
//    func displayPhoto(at index: Int, _ photoData: Data)
//    func displayPhoto(_ photoData: Data, _ isAllPhotosFetched: Bool)
//}
//
//final class PhotoSelectorPresenter: PhotoUseCaseOutput {
//    private let view: PhotoSelectorView
//
//    init(view: PhotoSelectorView) {
//        self.view = view
//    }
//
//    func fetchRequestedPhotoSucceeded(at index: Int, _ image: UIImage?) {
//        view.displayImage(at: index, image: image)
//    }
//
//    func photosCount(_ count: Int) {
//        view.preparePhotoCells(of: count)
//    }
//
//    func fetchPhotosSucceeded(at index: Int, _ photoData: Data) {
//        view.displayPhoto(at: index, photoData)
//    }
//
//    func fetchPhotosSucceeded(_ photoData: Data, _ isAllPhotosFetched: Bool) {
//        view.displayPhoto(photoData, isAllPhotosFetched)
//    }
//
//    func fetchPhotosFailed(_ error: PhotoUseCase.Error) {
//        view.displayError(error.localizedDescription)
//    }
//
//    func savePhotoSucceeded() {
//
//    }
//
//    func savePhotoFailed(_ error: PhotoUseCase.Error) {
//
//    }
//}
//
//extension WeakRef: PhotoSelectorView where T: PhotoSelectorView {
//    func displayImage(at index: Int, image: UIImage?) {
//        object?.displayImage(at: index, image: image)
//    }
//
//    func displayPhoto(at index: Int, _ photoData: Data) {
//        object?.displayPhoto(at: index, photoData)
//    }
//
//    func preparePhotoCells(of count: Int) {
//        object?.preparePhotoCells(of: count)
//    }
//
//    func displayPhoto(_ photoData: Data, _ isAllPhotosFetched: Bool) {
//        object?.displayPhoto(photoData, isAllPhotosFetched)
//    }
//}
