//
//  TopResponse.swift
//  redditTest
//
//  Created by Laureano De Andrea on 11/24/19.
//  Copyright © 2019 Laureano De Andrea. All rights reserved.
//

import Foundation

struct TopResponse:Codable {
    var kind: String
    var data: TopResponseData
}

struct TopResponseData: Codable {
    var modhash: String
    var dist: Int?
    var children: [TopResponseChildren]
    var after: String?
    var before: String?
}

struct TopResponseChildren: Codable {
    
    var kind: String
    var data: TopResponseChildrenData
    
}

struct TopResponseChildrenData: Codable {
    
    var id: String
    var author: String
    var title: String
    var num_comments: Int
    var created_utc: Int32 //date
    var thumbnail: String //url image
    
    func getCreatedDate() -> Date? {
        return Date(milliseconds: Int64(created_utc))
    }
    
}
