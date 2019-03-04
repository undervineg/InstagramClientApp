//
//  MyNewsViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 21/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine
import XLPagerTabStrip

final class MyNewsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    let type: PushNotificationType = .myNews
    
    // MARK: Commands
    var loadAllNotifications: ((String?) -> Void)?
    
    var loadProfileImage: ((NSUUID, NSString, ((UIImage?) -> Void)?) -> Void)?
    var getCachedProfileImage: ((NSUUID) -> UIImage?)?
    var cancelLoadProfileImage: ((NSUUID) -> Void)?
    
    var loadPostImage: ((NSUUID, NSString, ((UIImage?) -> Void)?) -> Void)?
    var getCachedPostImage: ((NSUUID) -> UIImage?)?
    var cancelLoadPostImage: ((NSUUID) -> Void)?
    
    // MARK: Models
    private var notifications: [PushNotificationObject] = [] {
        didSet {
            state = (notifications.count > 0) ? .loaded : .noData
        }
    }
    
    private var state: PageState = .noData {
        didSet {
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Initializer
    convenience init() {
        self.init(style: .plain)
    }
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        
        setupRefreshControl()
        
        tableView.register(ButtonNewsCell.nibFromClassName(), forCellReuseIdentifier: ButtonNewsCell.reuseId)
        tableView.register(ImageNewsCell.nibFromClassName(), forCellReuseIdentifier: ImageNewsCell.reuseId)
        tableView.register(NotificationDefaultCell.self, forCellReuseIdentifier: NotificationDefaultCell.reuseId)
        
        tableView.separatorStyle = .none
        
        tableView.prefetchDataSource = self
        
        loadAllNotifications?(nil)
    }
    
    // MARK: Actions
    @objc private func refresh(_ sender: UIRefreshControl) {
        notifications.removeAll()
        loadAllNotifications?(nil)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch state {
        case .noData: return view.frame.height
        case .loaded: return UITableView.automaticDimension
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .noData: return 1
        case .loaded: return notifications.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .noData:
            return tableView.dequeueReusableCell(withIdentifier: NotificationDefaultCell.reuseId, for: indexPath)
        case .loaded:
            let notification = notifications[indexPath.row]
            
            let cell: NotificationCell = (notification.data.detailButtonType == nil) ? tableView.dequeueReusableCell(for: indexPath) as ImageNewsCell : tableView.dequeueReusableCell(for: indexPath) as ButtonNewsCell
            
            return configuredCell(for: cell, notification)
        }
    }
    
    private func configuredCell(for cell: NotificationCell?, _ notification: PushNotificationObject) -> UITableViewCell {
        cell?.configure(with: notification.data)
        cell?.representedId = notification.uuid
        
        if let cachedProfileImage = getCachedProfileImage?(notification.uuid as NSUUID) {
            cell?.profileImageView?.image = cachedProfileImage
        } else {
            let urlString = notification.data.profileImageUrl as NSString
            loadProfileImage?(notification.uuid as NSUUID, urlString) { (fetchedImage) in
                DispatchQueue.main.async {
                    guard cell?.representedId == notification.uuid else { return }
                    cell?.profileImageView?.image = fetchedImage
                }
            }
        }
        
        if let cachedPostImage = getCachedPostImage?(notification.uuid as NSUUID) {
            cell?.postImageView?.image = cachedPostImage
        } else if let urlString = notification.data.detailImageUrls?.first as NSString? {
            loadPostImage?(notification.uuid as NSUUID, urlString) { (fetchedImage) in
                DispatchQueue.main.async {
                    guard cell?.representedId == notification.uuid else { return }
                    cell?.postImageView?.image = fetchedImage
                }
            }
        }
        
        return cell as! UITableViewCell
    }
    
    // MARK: Prefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard notifications.count - 1 > $0.item else { return }
            let notification = notifications[$0.row]
            let profileUrlString = notification.data.profileImageUrl as NSString
            loadProfileImage?(notification.uuid as NSUUID, profileUrlString, nil)
            
            if notification.data.detailButtonType == nil {
                if let postUrlString = notification.data.detailImageUrls?.first as NSString? {
                   loadPostImage?(notification.uuid as NSUUID, postUrlString, nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard notifications.count - 1 > $0.item else { return }
            let notification = notifications[$0.row]
            cancelLoadProfileImage?(notification.uuid as NSUUID)
            
            if notification.data.detailButtonType == nil {
                cancelLoadPostImage?(notification.uuid as NSUUID)
            }
        }
    }
}

extension MyNewsViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "내 소식")
    }
}

extension MyNewsViewController: NotificationView {
    func displayNotification(_ notification: PushNotification) {
        guard notification.type == self.type else { return }
        self.notifications.append(PushNotificationObject(notification))
        self.notifications.sort { (p1, p2) -> Bool in
            p1.data.creationDate.compare(p2.data.creationDate) == .orderedDescending
        }
    }
}

extension MyNewsViewController {
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: NotificationCell {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseId, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseId)")
        }
        return cell
    }
}
