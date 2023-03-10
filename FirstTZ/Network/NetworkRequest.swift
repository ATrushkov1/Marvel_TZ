//
//  NetworkRequest.swift
//  FirstTZ
//
//  Created by Алексей Трушков on 28.12.2022.
//

import Foundation
import UIKit

class NetworkRequest {
    
    static let shared = NetworkRequest()
    private init() {}
    
    func requestData(completion: @escaping (Result<Data, Error>) -> Void) {
        
        let urlString = "https://static.upstarts.work/tests/marvelgram/klsZdDg50j2.json"
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, respounce, error) in DispatchQueue.main.async {
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {return}
            completion(.success(data))
        }
        }
        .resume()
    }
    
}
