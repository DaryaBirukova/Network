//
//  WebsiteDescription.swift
//  Networking
//
//  Created by Дарья Бирюкова on 10.11.2022.
//

import Foundation

struct WebsiteDescription: Decodable {
    
    let websiteDescription: String
    let websiteName: String
    let courses: [Course]
}
