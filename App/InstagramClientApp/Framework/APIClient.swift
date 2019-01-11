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
    func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

extension URLSession: APIClient {
    func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let error = NSError(domain: "Data not exist", code: 0)
                completion(.failure(error))
                return
            }
            completion(.success(data))
        }.resume()
    }
}
