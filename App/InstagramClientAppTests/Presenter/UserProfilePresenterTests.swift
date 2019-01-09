//
//  UserProfilePresenterTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
import InstagramEngine
@testable import InstagramClientApp

class UserProfilePresenterTests: XCTestCase {

    func test_loadUserSucceeded_displayUsernameAsTitle() {
        let view = UserProfileViewStub()
        let sut = UserProfilePresenter(view: view)
        let user = UserEntity(id: "0",
                              email: "dummy@naver.com",
                              username: "dummy",
                              profileImageUrl: "http://a-url.com")
        
        sut.loadUserSucceeded(user)
        
        XCTAssertEqual(view.stubbedTitle, [user.username])
    }

    
    // MARK: - Helpers
    
    private class UserProfileViewStub: UserProfileView {
        var stubbedTitle = [String]()
        
        func displayTitle(_ title: String) {
            stubbedTitle.append(title)
        }
    }
        
}
