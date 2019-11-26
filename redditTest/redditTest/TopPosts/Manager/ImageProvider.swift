//
//  ImageProvider.swift
//  redditTest
//
//  Created by Laureano De Andrea on 11/25/19.
//  Copyright © 2019 Laureano De Andrea. All rights reserved.
//

import Foundation
import UIKit

protocol ImageProviderProtocol {
    func didGetImageSuccess(image: UIImage)
    func didGetImageFailure(error: String)
}

class ImageProvider {
    
    var delegate: ImageProviderProtocol?
    
    func getImage(fromUrl: String) {
        
        if let cachedImage = ImageCache.vault.object(forKey: fromUrl as NSString) {
            self.delegate?.didGetImageSuccess(image: cachedImage)
        } else {
            let repo = ImageRepository()
            if let url = URL(string: fromUrl) {
                repo.downloadImage(url: url) { (result) in
                    switch result {
                    case .failure(let error):
                        self.delegate?.didGetImageFailure(error: error.localizedDescription)
                        break
                    case .success(let img):
                        self.delegate?.didGetImageSuccess(image: img)
                        break
                    }
                }
            } else {
                delegate?.didGetImageFailure(error: "Bad URL!")
            }
        }
        
    }
    
    static func flush() {
        ImageCache.vault.removeAllObjects()
    }
    
}

fileprivate class ImageCache {

    static let vault = NSCache<NSString, UIImage>()
    private init () { }
    
}
