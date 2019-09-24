//
//  Image.swift
//  StockFilter
//
//  Created by Mete Cakman on 24/09/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import Foundation

/// Image description data model type for our API Image objects
struct Image: Decodable {
    
    let id: Int
    let thumbUrl: String
    let url: String
    let title: String?
    let author: String?
    let updated: String

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case thumbUrl = "thumb_url"
        case url = "url"
        case title = "title"
        case author = "author"
        case updated = "updated"
    }
}

/// Capture our JSON reponse root level data
struct ImageResponse: Decodable {
    let images: [Image]
}
