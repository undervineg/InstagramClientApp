//
//  Date+Extension.swift
//  InstagramClientApp
//
//  Created by 심승민 on 21/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 30 * day
        let year = 12 * month
        
        if secondsAgo < minute {
            return "\(secondsAgo) seconds ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) minutes ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        } else if secondsAgo < month {
            return "\(secondsAgo / week) weeks ago"
        } else if secondsAgo < year {
            return "\(secondsAgo / month) months ago"
        }

        return "\(secondsAgo / year) years ago"
    }
}
