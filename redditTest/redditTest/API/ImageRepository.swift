//
//  ImageRepository.swift
//  redditTest
//
//  Created by Laureano De Andrea on 11/25/19.
//  Copyright © 2019 Laureano De Andrea. All rights reserved.
//

import Foundation
import UIKit

class ImageRepository {
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func downloadImage(url: URL, completion: @escaping ((Result<UIImage>) -> Void)) {
        
        dataTask?.cancel()
        
        let err = NSError(domain: "", code: 1, userInfo: nil)
        
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
            let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
            let data = data, error == nil,
            let image = UIImage(data: data)
            else {
                completion(.failure(error ?? err as Error))
                return
            }
            
            completion(.success(image))
            
        }
        
        dataTask?.resume()
        
    }
    
}
