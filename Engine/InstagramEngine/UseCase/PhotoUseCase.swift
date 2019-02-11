//
//  LoadPhotoUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

public protocol PhotoClient {
    func fetchAllPhotos(order: Photo.Order) -> Int
    func startCachingPhotos(at indexes: [Int], width: Float, height: Float)
    func stopCachingPhotos(at indexes: [Int])
    func resetCache()
    func getAssetInfo(at index: Int) -> PhotoAsset?
    func requestImage(at index: Int, width: Float, height: Float, _ completion: @escaping (UIImage?) -> Void)

//    func fetchPhotos(limit: Int, order: Photo.Order, _ completion: @escaping (Result<(Data, Bool), PhotoUseCase.Error>) -> Void)
    func savePhoto(_ photoData: Data, _ completion: @escaping (PhotoUseCase.Error?) -> Void)
}

public protocol PhotoUseCaseOutput {
//    func fetchRequestedPhotoSucceeded(at index: Int, _ image: UIImage?)
    
//    func photosCount(_ count: Int)
//    func fetchPhotosSucceeded(at index: Int, _ photoData: Data)
//    func fetchPhotosSucceeded(_ photoData: Data, _ isAllPhotosFetched: Bool)
//    func fetchPhotosFailed(_ error: PhotoUseCase.Error)
    func savePhotoSucceeded()
    func savePhotoFailed(_ error: PhotoUseCase.Error)
}

final public class PhotoUseCase {
    
    private let client: PhotoClient
    private let output: PhotoUseCaseOutput?
    
    public init(client: PhotoClient, output: PhotoUseCaseOutput?) {
        self.client = client
        self.output = output
    }
    
    public enum Error: Swift.Error {
        case dataNotExist
        case networkError
        case saveError
        
        public var localizedDescription: String {
            switch self {
            case .dataNotExist: return "일부 사진을 찾을 수 없습니다."
            case .networkError: return "네트워크 연결을 확인해주세요."
            case .saveError: return "사진첩에 사진을 저장할 수 없습니다."
            }
        }
    }
    
    public func assetInfo(at index: Int) -> PhotoAsset? {
        return client.getAssetInfo(at: index)
    }
    
    public func requestImage(at index: Int, width: Float, height: Float, _ completion: @escaping (UIImage?) -> Void) {
        client.requestImage(at: index, width: width, height: height) { (image) in
            completion(image)
//            self?.output.fetchRequestedPhotoSucceeded(at: index, image)
        }
    }
    
    public func loadAllPhotos(order: Photo.Order) -> Int {
        return client.fetchAllPhotos(order: order)
    }
    
    public func startCachingPhotos(at indexes: [Int], width: Float, height: Float) {
        client.startCachingPhotos(at: indexes, width: width, height: height)
    }
    
    public func stopCachingPhotos(at indexes: [Int]) {
        client.stopCachingPhotos(at: indexes)
    }
    
    public func resetCachedPhotos() {
        client.resetCache()
    }
    
//    public func loadPhotos(limit: Int, order: Photo.Order) {
//        client.fetchPhotos(limit: limit, order: order) { (result) in
//            switch result {
//            case .success(let (data, isAllPhotosFetched)):
//                self.output.fetchPhotosSucceeded(data, isAllPhotosFetched)
//            case .failure(let error):
//                self.output.fetchPhotosFailed(error)
//            }
//        }
//    }
    
    public func savePhoto(_ photoData: Data) {
        client.savePhoto(photoData) { (error) in
            if let error = error {
                self.output?.savePhotoFailed(error)
                return
            }
            self.output?.savePhotoSucceeded()
        }
    }
}
