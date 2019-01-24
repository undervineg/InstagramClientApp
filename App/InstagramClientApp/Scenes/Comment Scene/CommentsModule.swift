//
//  CommentsModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 25/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine
import UIKit

final class CommentsModule {
    let viewController: UIViewController
    
    init(post: Post) {
        viewController = CommentsViewController(currentPost: post)
    }
}
