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
    
    // MARK: Models
    private var notifications: [PushNotificationObject] = []
    
    // MARK: Initializer
    convenience init() {
        self.init(style: .plain)
    }
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        
        setupRefreshControl()
        
        tableView.register(MyNewsCell.nibFromClassName(), forCellReuseIdentifier: MyNewsCell.reuseId)
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyNewsCell.reuseId, for: indexPath) as! MyNewsCell

        let notification = notifications[indexPath.row]
        cell.configure(with: notification.data)
        cell.representedId = notification.uuid
        
        if let cachedProfileImage = getCachedProfileImage?(notification.uuid as NSUUID) {
            cell.profileImageView?.image = cachedProfileImage
        } else {
            let urlString = notification.data.profileImageUrl as NSString
            loadProfileImage?(notification.uuid as NSUUID, urlString) { (fetchedImage) in
                DispatchQueue.main.async {
                    guard cell.representedId == notification.uuid else { return }
                    cell.profileImageView?.image = fetchedImage
                }
            }
        }
        
        return cell
    }
    
    // MARK: Prefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            let notification = notifications[$0.row]
            let urlString = notification.data.profileImageUrl as NSString
            loadProfileImage?(notification.uuid as NSUUID, urlString, nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            let notification = notifications[$0.row]
            cancelLoadProfileImage?(notification.uuid as NSUUID)
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
        
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
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
