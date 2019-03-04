//
//  LoadPhotoUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

public protocol PhotoClient {
    func assetCount() -> Int
    func savePhoto(_ photoData: Data, _ completion: @escaping (PhotoUseCase.Error?) -> Void)
    func getAssetInfo(at index: Int) -> PhotoAsset?
    func requestImage(at index: Int, width: Float, height: Float, _ completion: @escaping (UIImage?) -> Void)
    func fetchAllPhotos(order: Photo.Order)
    func startCachingPhotos(at indexes: [Int], width: Float, height: Float)
    func stopCachingPhotos(at indexes: [Int])
    func resetCache()
}

public protocol PhotoUseCaseOutput {
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
