//
//  RedditProvider.swift
//  redditTest
//
//  Created by Laureano De Andrea on 11/24/19.
//  Copyright © 2019 Laureano De Andrea. All rights reserved.
//

import Foundation

protocol RedditProviderProtocol {
    func didGetTopPostsSuccess(object: TopResponse )
    func didGetTopPostFailure(erorr: String)
}

class RedditProvider {
    
    var delegate: RedditProviderProtocol?
    
    func getTopPosts(afterHash: String = "") {
        
        let repo = RedditRepository()
        
        repo.getTop50Posts(afterHash: afterHash) { (result) in
            switch result {
            case .failure(let error):
                self.delegate?.didGetTopPostFailure(erorr: error.localizedDescription)
                break
            case .success(let response):
                self.delegate?.didGetTopPostsSuccess(object: response)
                break
            }
        }
        
    }
    
}
