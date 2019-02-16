//
//  APIClient.swift
//  InstagramClientApp
//
//  Created by 심승민 on 11/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine
import Foundation

protocol APIClient {
    func get(from url: URL, completion: @escaping (Result<Data?, Error>) -> Void)
}

final class URLSessionManager: APIClient {
    func get(from url: URL, completion: @escaping (Result<Data?, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(data))
        }.resume()
    }
}
