//
//  main.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

private func delegateClassName() -> String {
    let isTesting = NSClassFromString("XCTestCase") != nil
    return isTesting ? "InstagramClientAppTests.StubAppDelegate" : NSStringFromClass(AppDelegate.self)
}

UIApplicationMain(CommandLine.argc, UnsafeMutablePointer(CommandLine.unsafeArgv), nil, delegateClassName())
