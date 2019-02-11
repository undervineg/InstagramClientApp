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
    private let photos: PhotosWrapper
    
    init(photos: PhotosWrapper) {
        self.photos = photos
    }
    
    func getAssetInfo(at index: Int) -> PhotoAsset? {
        return photos.getAssetInfo(at: index)
    }
    
    func requestImage(at index: Int, width: Float, height: Float, _ completion: @escaping (UIImage?) -> Void) {
        let targetSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        photos.requestImage(at: index, sizeOf: targetSize, completion)
    }
    
    func fetchAllPhotos(order: Photo.Order) -> Int {
        return photos.fetchAllPhotos(order: order)
    }
    
    func startCachingPhotos(at indexes: [Int], width: Float, height: Float) {
        let targetSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        photos.startCaching(at: indexes, sizeOf: targetSize)
    }
    
    func stopCachingPhotos(at indexes: [Int]) {
        photos.stopCaching(at: indexes)
    }
    
    func resetCache() {
        photos.resetCacheAssets()
    }
    
    func startLoadPhotos(order: Photo.Order, _ completion: @escaping (Int) -> Void) {
        photos.startLoadAllPhotos(order: order, completion)
    }
    
    func fetchPhotos(at indexes: [Int], order: Photo.Order, _ completion: @escaping (Result<(Int, Data), PhotoUseCase.Error>) -> Void) {
        photos.fetchPhotos(at: indexes, order: order) { (idx, data) in
            guard let data = data else {
                completion(.failure(.dataNotExist))
                return
            }
            completion(.success((idx, data)))
        }
    }
    
    func fetchPhotos(limit: Int, order: Photo.Order, _ completion: @escaping (Result<(Data, Bool), PhotoUseCase.Error>) -> Void) {
        photos.fetchPhotos(limit: limit, order: order) { (data, isAllPhotosFetched) in
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
