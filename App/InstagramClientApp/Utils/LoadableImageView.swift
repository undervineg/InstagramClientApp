//
//  LoadableImageView.swift
//  InstagramClientApp
//
//  Created by 심승민 on 18/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

protocol ImageLoadable: class {
    var cacheManager: Cacheable? { get set }
    var lastUrlRequested: String? { get set }
    
    func loadImage(from urlString: String, using callback: ((URL, @escaping (Data) -> Void) -> Void)?)
    func loadImage(from urlString: String, using callback: ((URL, @escaping (Result<Data, UserProfileUseCase.Error>) -> Void) -> Void)?)
}

extension ImageLoadable where Self: UIImageView {
    func loadImage(from urlString: String, using callback: ((URL, @escaping (Data) -> Void) -> Void)?) {
        lastUrlRequested = urlString
        if let url = URL(string: urlString) {
            if let cachedImageData = cacheManager?.getCachedData(key: url.absoluteString) {
                image = UIImage(data: cachedImageData)
                return
            }
            callback?(url) { [weak self] imageData in
                guard url.absoluteString == self?.lastUrlRequested else { return }
                DispatchQueue.main.async {
                    self?.cacheManager?.cache(imageData, with: url.absoluteString)
                    self?.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    func loadImage(from urlString: String, using callback: ((URL, @escaping (Result<Data, UserProfileUseCase.Error>) -> Void) -> Void)?) {
        lastUrlRequested = urlString
        if let url = URL(string: urlString) {
            if let cachedImageData = cacheManager?.getCachedData(key: url.absoluteString) {
                image = UIImage(data: cachedImageData)
                return
            }
            callback?(url) { [weak self] result in
                guard url.absoluteString == self?.lastUrlRequested else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let imageData):
                        self?.cacheManager?.cache(imageData, with: url.absoluteString)
                        self?.image = UIImage(data: imageData)
                    default: return
                    }
                }
            }
        }
    }
}

final class LoadableImageView: UIImageView, ImageLoadable {
    var cacheManager: Cacheable?
    var lastUrlRequested: String?
}
