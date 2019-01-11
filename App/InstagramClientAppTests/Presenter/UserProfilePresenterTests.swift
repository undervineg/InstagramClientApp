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

    func test_loadUserFailed_displayCurrentUserNotExistError() {
        let view = UserProfileViewStub()
        let sut = UserProfilePresenter(view: view)
        
        sut.loadUserFailed(.currentUserIDNotExist)
        sut.loadUserFailed(.currentUserNotExist)
        
        XCTAssertEqual(view.stubbedErrorMessage, [
            "사용자 계정이 없습니다.",
            "사용자 정보가 없습니다."
        ])
    }
    
    // MARK: - Helpers
    
    private class UserProfileViewStub: UserProfileView {
        var stubbedTitle = [String]()
        var stubbedImageData = [Data]()
        var stubbedErrorMessage = [String]()
        
        func displayUserInfo(_ user: UserEntity) {
            stubbedTitle.append(user.username)
        }
        
        func displayProfileImage(_ imageData: Data) {
            stubbedImageData.append(imageData)
        }
        
        func displayError(_ errorMessage: String) {
            stubbedErrorMessage.append(errorMessage)
        }
    }
        
}
