//
//  CommentRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 24/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

protocol CommentsRoute {
    var commentsTransition: Transition { get }
    
    func openCommentsPage(postId: String)
    func openCommentsPage(postId: String, with transition: Transition)
}
