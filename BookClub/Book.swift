//
//  Book.swift
//  BookClub
//

import Foundation

// Simple model for one book recommendation.
struct Book {
    var id: String
    var title: String
    var author: String
    var genre: String
    var review: String
    var rating: Int
    // Used to show newest books first.
    var createdAt: Date
}
