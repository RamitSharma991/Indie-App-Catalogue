//
//  Article.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import Foundation

struct Article: Identifiable, Codable {
    let id: UUID
    let title: String
    let summary: String
    let content: String
    let author: String
    let publishDate: Date
    let imageURL: URL?
    let sourceURL: URL?
    let category: Category
    
    enum Category: String, Codable, CaseIterable {
        case ai = "AI & Machine Learning"
        case gadgets = "Gadgets"
        case startups = "Startups"
        case cybersecurity = "Cybersecurity"
        case gaming = "Gaming"
        case software = "Software Development"
    }
}