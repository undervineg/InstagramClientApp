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
    
    func fetchAllPhotos(limit: Int, isAscending: Bool, _ completion: @escaping (Result<(Data, Bool), LoadPhotoUseCase.Error>) -> Void) {
        photos.fetchAllPhotos(limit: limit, isAscending: isAscending) { (data, isAllPhotosFetched) in
            guard let data = data else {
                completion(.failure(.dataNotExist))
                return
            }
            completion(.success((data, isAllPhotosFetched)))
        }
    }
}
