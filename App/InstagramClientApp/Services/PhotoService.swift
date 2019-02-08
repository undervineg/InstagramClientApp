//
//  PhotoService.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

final class PhotoService: PhotoClient {
    private let photos: PhotosWrapper.Type
    
    init(photos: PhotosWrapper.Type) {
        self.photos = photos
    }
    
    func fetchAllPhotos(limit: Int, order: Photo.Order, _ completion: @escaping (Result<(Data, Bool), PhotoUseCase.Error>) -> Void) {
        photos.fetchAllPhotos(limit: limit, order: order) { (data, isAllPhotosFetched) in
            guard let data = data else {
                completion(.failure(.dataNotExist))
                return
            }
            completion(.success((data, isAllPhotosFetched)))
        }
    }
    
    func savePhoto(_ photoData: Data, _ completion: @escaping (PhotoUseCase.Error?) -> Void) {
        photos.savePhoto(data: photoData) { (error) in
            if error != nil {
                completion(.saveError)
                return
            }
            completion(nil)
        }
    }
}

extension Photo.Order: HasKey, Sortable {
    var sortBy: Sort {
        switch self {
        case .creationDate(let sort): return sort
        }
    }
    
    var key: String {
        switch self {
        case .creationDate: return Keys.Database.Post.Contents.creationDate
        }
    }
}
