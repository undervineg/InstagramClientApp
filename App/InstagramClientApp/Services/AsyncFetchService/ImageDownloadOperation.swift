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

final class ImageDownloadOperation: CustomOperation<NSUUID, NSString, UIImage> {
    override func main() {
        guard !isCancelled else { return }
        
        guard let url = URL(string: model as String) else { return }
        
        if let data = try? Data(contentsOf: url) {
            self.fetchedData = UIImage(data: data)
        } else {
            self.fetchedData = UIImage(color: UIColor(red: 244/255, green: 246/255, blue: 249/255, alpha: 1))
        }
    }
}
