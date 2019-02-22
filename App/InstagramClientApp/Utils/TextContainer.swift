//
//  TextContainer.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol TextContainer {
    var textInside: String? { get }
    
    func trimmedText() -> String?
    func hasBlanks() -> Bool
}

extension TextContainer {
    func trimmedText() -> String? {
        return textInside?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func hasBlanks() -> Bool {
        guard let text = textInside else { return true }
        return text.contains(" ") || text.contains("\t") || text.contains("\n")
    }
}

extension UITextView: TextContainer {
    var textInside: String? {
        return self.text
    }
}

extension UITextField: TextContainer {
    var textInside: String? {
        return self.text
    }
}
