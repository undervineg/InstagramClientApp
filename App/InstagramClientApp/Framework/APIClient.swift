//
//  APIClient.swift
//  InstagramClientApp
//
//  Created by 심승민 on 11/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

protocol APIClient {
    func downloadData(from urlString: String, completion: @escaping (Data) -> Void)
}

extension URLSession: APIClient {
    func downloadData(from urlString: String, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
            }
            guard let data = data else {
                return
            }
            completion(data)
            }.resume()
    }
}
