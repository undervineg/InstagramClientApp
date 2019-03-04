//
//  SharePhotoUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol SharePhotoClient {
    func share(_ data: Data, _ caption: String, _ imageWidth: Float, _ imageHeight: Float, _ uploadDate: Double, completion: @escaping (Error?) -> Void)
}

public protocol SharePhotoUseCaseOutput {
    func shareSucceeded()
    func shareFailed(_ error: Error)
}

final public class SharePhotoUseCase {
    private let client: SharePhotoClient
    private let output: SharePhotoUseCaseOutput
    
    public init(client: SharePhotoClient, output: SharePhotoUseCaseOutput) {
        self.client = client
        self.output = output
    }
    
    public func share(_ data: Data, _ caption: String, _ imageWidth: Float, _ imageHeight: Float, _ uploadDate: Double) {
        client.share(data, caption, imageWidth, imageHeight, uploadDate) { [weak self] (error) in
            if let error = error {
                self?.output.shareFailed(error)
                return
            }
            self?.output.shareSucceeded()
            
            NotificationCenter.default.post(name: NotificationName.shareNewFeed, object: nil)
        }
    }
}
