//
//  PhotosWrapper.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Photos

protocol PhotosWrapper {
    static func fetchAllPhotos(limit: Int, isAscending: Bool, _ completion: @escaping (Data?, Bool) -> Void)
}

extension PHAsset: PhotosWrapper {
    static func fetchAllPhotos(limit: Int = 10, isAscending: Bool, _ completion: @escaping (Data?, Bool) -> Void) {
        let options = PHFetchOptions()
        options.fetchLimit = limit
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: isAscending)
        options.sortDescriptors = [sortDescriptor]
        
        DispatchQueue.global(qos: .background).async {
            let allPhotos = fetchAssets(with: .image, options: options)
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                imageManager.requestImageData(for: asset, options: options, resultHandler: { (data, filename, orientation, info) in
                    let isAllPhotosFetched = (count == allPhotos.count - 1)
                    completion(data, isAllPhotosFetched)
                })
            }
        }
    }
}
