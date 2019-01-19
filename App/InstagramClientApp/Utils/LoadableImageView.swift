//
//  LoadableImageView.swift
//  InstagramClientApp
//
//  Created by 심승민 on 18/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol ImageLoadable: class {
    var lastUrlRequested: String? { get set }
    
    func loadImage(from urlString: String, using downloadPostImage: ((URL, @escaping (Data) -> Void) -> Void)?)
}

extension ImageLoadable where Self: UIImageView {
    func loadImage(from urlString: String, using downloadPostImage: ((URL, @escaping (Data) -> Void) -> Void)?) {
        lastUrlRequested = urlString
        if let url = URL(string: urlString) {
            downloadPostImage?(url) { [weak self] imageData in
                guard url.absoluteString == self?.lastUrlRequested else { return }
                DispatchQueue.main.async {
                    self?.image = UIImage(data: imageData)
                }
            }
        }
    }
}

final class LoadableImageView: UIImageView, ImageLoadable {
    var lastUrlRequested: String?
}
