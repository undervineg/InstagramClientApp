//
//  UserProfileVCTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
import InstagramEngine
@testable import InstagramClientApp

class UserProfileVCTests: XCTestCase {
    
    func test_loadProfile_whenViewWillAppear() {
        let sut = UserProfileViewController()
        _ = sut.view
        
        var callCount = 0
        sut.loadProfile = {
            callCount += 1
        }
        
        sut.viewWillAppear(false)
        
        XCTAssertEqual(callCount, 1)
    }

    func test_displayTitle_setTitleOnNavigationBar() {
        let sut = UserProfileViewController()
        _ = sut.view
        let user = User(id: "0",
                              email: "dummy@naver.com",
                              username: "dummyUser",
                              profileImageUrl: "http://a-url.com")
        
        sut.displayUserInfo(user)
        
        XCTAssertEqual(sut.navigationItem.title, "dummyUser")
    }

}
