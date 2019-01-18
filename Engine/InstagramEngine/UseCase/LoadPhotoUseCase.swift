//
//  LoadPhotoUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol PhotoClient {
    func fetchAllPhotos(limit: Int, isAscending: Bool, _ completion: @escaping (Result<(Data, Bool), LoadPhotoUseCase.Error>) -> Void)
}

public protocol LoadPhotoUseCaseOutput {
    func fetchAllPhotosSucceeded(_ photoData: Data, _ isAllPhotosFetched: Bool)
    func fetchAllPhotosFailed(_ error: LoadPhotoUseCase.Error)
}

final public class LoadPhotoUseCase {
    
    private let client: PhotoClient
    private let output: LoadPhotoUseCaseOutput
    
    public init(client: PhotoClient, output: LoadPhotoUseCaseOutput) {
        self.client = client
        self.output = output
    }
    
    public enum Error: Swift.Error {
        case dataNotExist
        case networkError
    }
    
    public func loadAllPhotos(limit: Int, isAscending: Bool) {
        client.fetchAllPhotos(limit: limit, isAscending: isAscending) { (result) in
            switch result {
            case .success(let (data, isAllPhotosFetched)):
                self.output.fetchAllPhotosSucceeded(data, isAllPhotosFetched)
            case .failure(let error):
                self.output.fetchAllPhotosFailed(error)
            }
        }
    }
}
