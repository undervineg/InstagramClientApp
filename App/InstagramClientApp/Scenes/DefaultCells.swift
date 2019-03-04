//
//  DefaultCells.swift
//  InstagramClientApp
//
//  Created by 심승민 on 03/03/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class NotificationDefaultCell: UITableViewCell {
    
    static let reuseId = "NotificationDefaultCell"
    
    let label: UILabel = {
        let lb = UILabel()
        lb.text = "알림이 없습니다."
        lb.font = UIFont.systemFont(ofSize: 27)
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

final class ProfileDefaultCell: UICollectionViewCell {
    
    static let reuseId = "GridDefaultCell"
    
    let label: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 27)
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with text: String) {
        label.text = text
    }
}

final class FeedDefaultCell: UICollectionViewCell {
    
    static let reuseId = "FeedDefaultCell"
    
    let label: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 27)
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with text: String) {
        label.text = text
    }
}

final class SearchDefaultCell: UICollectionViewCell {
    static let reuseId = "SearchDefaultCell"
    
    let label: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 27)
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with text: String) {
        label.text = text
    }
}
