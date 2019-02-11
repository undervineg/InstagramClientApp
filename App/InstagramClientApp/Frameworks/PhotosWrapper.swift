//
//  PhotosWrapper.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Photos
import InstagramEngine

protocol PhotosWrapper {
    func fetchAllPhotos(order: HasKey&Sortable) -> Int
    func startCaching(at indexes: [Int], sizeOf targetSize: CGSize)
    func stopCaching(at indexes: [Int])
    func resetCacheAssets()
    func getAssetInfo(at index: Int) -> PhotoAsset?
    func requestImage(at index: Int, sizeOf targetSize: CGSize, _ completion: @escaping (UIImage?) -> Void)
    
    func startLoadAllPhotos(order: HasKey&Sortable, _ completion: @escaping (Int) -> Void)
    func fetchPhotos(at indexes: [Int], order: HasKey&Sortable, _ completion: @escaping (Int, Data?) -> Void)
    func fetchPhotos(limit: Int, order: HasKey&Sortable, _ completion: @escaping (Data?, Bool) -> Void)
    func savePhoto(data: Data, _ completion: @escaping (Error?) -> Void)
}

final class PhotosManager: PhotosWrapper {
    private var fetchResult: PHFetchResult<PHAsset>?
    private let cachingImageManager = PHCachingImageManager()
    private var targetSize: CGSize = .zero
    
    func getAssetInfo(at index: Int) -> PhotoAsset? {
        guard let asset = fetchResult?.object(at: index) else { return nil }

        return PhotoAsset(identifier: asset.localIdentifier,
                          isLivePhoto: asset.mediaSubtypes.contains(.photoLive))
    }
    
    func requestImage(at index: Int, sizeOf targetSize: CGSize, _ completion: @escaping (UIImage?) -> Void) {
        guard let asset = fetchResult?.object(at: index) else { return }
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        cachingImageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, _) in
            completion(image)
        }
    }
    
    func fetchAllPhotos(order: HasKey&Sortable) -> Int {
        let options = PHFetchOptions()
        let isAscending = order.sortBy == .ascending
        let sortDescriptor = NSSortDescriptor(key: order.key, ascending: isAscending)
        options.sortDescriptors = [sortDescriptor]
        
        let result = PHAsset.fetchAssets(with: .image, options: options)
        fetchResult = result
        return result.count
    }
    
    func startCaching(at indexes: [Int], sizeOf targetSize: CGSize) {
        let assets = indexes.compactMap { (index) -> PHAsset? in
            return fetchResult?.object(at: index)
        }
        self.targetSize = targetSize
        cachingImageManager.startCachingImages(for: assets,
                                               targetSize: targetSize,
                                               contentMode: .aspectFit,
                                               options: nil)
    }
    
    func stopCaching(at indexes: [Int]) {
        let assets = indexes.compactMap { (index) -> PHAsset? in
            return fetchResult?.object(at: index)
        }
        cachingImageManager.stopCachingImages(for: assets,
                                              targetSize: targetSize,
                                              contentMode: .aspectFit,
                                              options: nil)
    }
    
    func resetCacheAssets() {
        cachingImageManager.stopCachingImagesForAllAssets()
    }
    
    func startLoadAllPhotos(order: HasKey&Sortable, _ completion: @escaping (Int) -> Void) {
        let options = PHFetchOptions()
        let isAscending = order.sortBy == .ascending
        let sortDescriptor = NSSortDescriptor(key: order.key, ascending: isAscending)
        options.sortDescriptors = [sortDescriptor]
        
        DispatchQueue.global(qos: .background).async {
            let fetchedPhotos = PHAsset.fetchAssets(with: .image, options: options)
            let allPhotosCount = fetchedPhotos.countOfAssets(with: .image)
            completion(allPhotosCount)
            
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            
            let assets = fetchedPhotos.objects(at: IndexSet(integersIn: 0..<allPhotosCount))
            self.cachingImageManager.startCachingImages(for: assets,
                                                        targetSize: CGSize(width: 350, height: 350),
                                                        contentMode: .aspectFit,
                                                        options: options)
        }
    }
    
    func startLoadPhotos(of indexes: [Int], order: HasKey&Sortable) {
        let options = PHFetchOptions()
        let isAscending = order.sortBy == .ascending
        let sortDescriptor = NSSortDescriptor(key: order.key, ascending: isAscending)
        options.sortDescriptors = [sortDescriptor]
        
        DispatchQueue.global(qos: .background).async {
            let fetchedPhotos = PHAsset.fetchAssets(with: .image, options: options)
            let assets = fetchedPhotos.objects(at: IndexSet(indexes))
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            self.cachingImageManager.startCachingImages(for: assets,
                                                   targetSize: CGSize(width: 350, height: 350),
                                                   contentMode: .aspectFit,
                                                   options: options)
        }
    }
    
    func fetchPhotos(at indexes: [Int], order: HasKey&Sortable, _ completion: @escaping (Int, Data?) -> Void) {
        let options = PHFetchOptions()
        let isAscending = order.sortBy == .ascending
        let sortDescriptor = NSSortDescriptor(key: order.key, ascending: isAscending)
        options.sortDescriptors = [sortDescriptor]
        
        DispatchQueue.global(qos: .background).async {
            let fetchedPhotos = PHAsset.fetchAssets(with: .image, options: options)
            fetchedPhotos.enumerateObjects { (asset, idx, stop) in
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                self.cachingImageManager.requestImageData(for: asset, options: options, resultHandler: { (data, filename, orientation, info) in
                    completion(idx, data)
                })
            }
        }
    }
    
    func fetchPhotos(limit: Int, order: HasKey&Sortable, _ completion: @escaping (Data?, Bool) -> Void) {
        let options = PHFetchOptions()
        options.fetchLimit = limit
        
        let isAscending = order.sortBy == .ascending
        let sortDescriptor = NSSortDescriptor(key: order.key, ascending: isAscending)
        options.sortDescriptors = [sortDescriptor]
        
        DispatchQueue.global(qos: .background).async {
            let fetchedPhotos = PHAsset.fetchAssets(with: .image, options: options)
            fetchedPhotos.enumerateObjects { (asset, idx, stop) in
                let imageManager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                imageManager.requestImageData(for: asset, options: options, resultHandler: { (data, filename, orientation, info) in
                    let isAllPhotosFetched = (idx == fetchedPhotos.count - 1)
                    completion(data, isAllPhotosFetched)
                })
            }
        }
    }
    
    func savePhoto(data: Data, _ completion: @escaping (Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            guard let image = UIImage.init(data: data) else { return }
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success, error) in
            completion(error)
        }
    }
}


//extension PHAsset: PhotosWrapper {
//    static func startLoadPhotos(of indexes: [Int], order: HasKey & Sortable) {
//
//    }
//
//    static func fetchPhotos(limit: Int, order: HasKey&Sortable, _ completion: @escaping (Data?, Bool) -> Void) {
//        let options = PHFetchOptions()
//        options.fetchLimit = limit
//
//        let isAscending = order.sortBy == .ascending
//        let sortDescriptor = NSSortDescriptor(key: order.key, ascending: isAscending)
//        options.sortDescriptors = [sortDescriptor]
//
//        DispatchQueue.global(qos: .background).async {
//            let fetchedPhotos = fetchAssets(with: .image, options: options)
//            fetchedPhotos.enumerateObjects { (asset, count, stop) in
//                let imageManager = PHImageManager.default()
//                let options = PHImageRequestOptions()
//                options.isSynchronous = true
//
//                imageManager.requestImageData(for: asset, options: options, resultHandler: { (data, filename, orientation, info) in
//                    let isAllPhotosFetched = (count == fetchedPhotos.count - 1)
//                    completion(data, isAllPhotosFetched)
//                })
//            }
//        }
//    }
//
//    static func savePhoto(data: Data, _ completion: @escaping (Error?) -> Void) {
//        PHPhotoLibrary.shared().performChanges({
//            guard let image = UIImage.init(data: data) else { return }
//            PHAssetChangeRequest.creationRequestForAsset(from: image)
//        }) { (success, error) in
//            completion(error)
//        }
//    }
//}
