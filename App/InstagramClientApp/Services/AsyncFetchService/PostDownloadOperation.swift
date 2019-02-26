//
//  PostDownloadOperation.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import Foundation
import InstagramEngine

final class PostDownloadOperation: CustomOperation<NSUUID, Post, PostObject> {
    override func main() {
        guard !isCancelled else { return }
        
        self.fetchedData = PostObject(model)
    }
}
