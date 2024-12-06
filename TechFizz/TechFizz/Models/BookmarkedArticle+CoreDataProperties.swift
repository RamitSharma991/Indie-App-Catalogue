//
//  BookmarkedArticle+CoreDataProperties.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//
//

import Foundation
import CoreData


extension BookmarkedArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmarkedArticle> {
        return NSFetchRequest<BookmarkedArticle>(entityName: "BookmarkedArticle")
    }

    @NSManaged public var author: String?
    @NSManaged public var content: String?
    @NSManaged public var id: UUID?
    @NSManaged public var imageURL: URL?
    @NSManaged public var publishDate: Date?
    @NSManaged public var sourceURL: URL?
    @NSManaged public var summary: String?
    @NSManaged public var title: String?

}

extension BookmarkedArticle : Identifiable {

}
