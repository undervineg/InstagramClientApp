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
    
    func savePhoto(data: Data, _ completion: @escaping (Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            guard let image = UIImage.init(data: data) else { return }
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success, error) in
            completion(error)
        }
    }
}
