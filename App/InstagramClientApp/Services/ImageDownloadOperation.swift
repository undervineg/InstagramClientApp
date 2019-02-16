//
//  ImageDownloadOperation.swift
//  InstagramClientApp
//
//  Created by 심승민 on 14/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import Foundation
import InstagramEngine

final class ImageDownloadOperation: CustomOperation<NSUUID, HasImageUrl, UIImage> {
    override func main() {
        guard !isCancelled else { return }
        
        guard let url = URL(string: model.imageUrl) else { return }
        
        if let data = try? Data(contentsOf: url) {
            self.fetchedData = UIImage(data: data)
        } else {
            self.fetchedData = UIImage(color: .lightGray)
        }
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
