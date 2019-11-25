//
//  RedditRepository.swift
//  redditTest
//
//  Created by Laureano De Andrea on 11/24/19.
//  Copyright © 2019 Laureano De Andrea. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}

class RedditRepository {
    
    let baseUrl = "http://reddit.com/r/funny.json"//?limit=50"
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?

    func getTop50Posts(_ completion: @escaping ((Result<TopResponse>) -> Void)) {
        
        dataTask?.cancel()
        
        var urlComps = URLComponents(string: baseUrl)
        urlComps?.queryItems = [URLQueryItem(name: "limit", value: "50")]
        
        guard let url = urlComps?.url else { return }
        
        dataTask = defaultSession.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                
                let responseObject:TopResponse = try! JSONDecoder().decode(TopResponse.self, from: data!)
                completion(.success(responseObject))
                
            }
            
        }
            
            
        dataTask?.resume()
        
    }
    
}
