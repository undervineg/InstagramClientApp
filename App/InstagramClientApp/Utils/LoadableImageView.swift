//
//  LoadableImageView.swift
//  InstagramClientApp
//
//  Created by 심승민 on 18/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

protocol LoadableImageViewDelegate {
    func requestImageDownload(_ loadableImageView: LoadableImageView, _ url: URL, _ completion: @escaping (Data) -> Void)
}

final class LoadableImageView: UIImageView {
    var cacheManager: Cacheable?
    var delegate: LoadableImageViewDelegate?
    
    var imageUrlString: String? { didSet { handleImageUrl() } }
    private var lastUrlRequested: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func handleImageUrl() {
        guard let urlString = imageUrlString, let url = URL(string: urlString) else { return }
        
        lastUrlRequested = urlString
        if let cachedImageData = cacheManager?.getCachedData(key: url.absoluteString) {
            image = UIImage(data: cachedImageData)
            return
        }
        delegate?.requestImageDownload(self, url) { [weak self] (imageData) in
            guard url.absoluteString == self?.lastUrlRequested else { return }
            DispatchQueue.main.async {
                self?.cacheManager?.cache(imageData, with: url.absoluteString)
                self?.image = UIImage(data: imageData)
            }
        }
    }
}
