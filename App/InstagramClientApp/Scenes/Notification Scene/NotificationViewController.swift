//
//  LikesViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 21/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

final class NotificationViewController: UITableViewController {

    // MARK: Commands
    var loadAllNotifications: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        service.loadAllNotifications(of: nil) { (result) in
            switch result {
            case .success(let notification): print(notification)
            case .failure(let error): print(error)
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        

        return cell
    }

}
