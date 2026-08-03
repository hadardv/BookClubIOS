//
//  FirestoreManager.swift
//  BookClub
//

import Foundation
import FirebaseFirestore

// Handles all Firestore read and write operations.
class FirestoreManager {

    // Shared instance so every screen can use the same manager.
    static let shared = FirestoreManager()

    // Reference to the Firestore database.
    private let db = Firestore.firestore()

    // Collection name in Firebase.
    private let collectionName = "books"

    // Listens for changes in the books collection.
    // Every time data changes, the completion handler is called.
    func listenToBooks(completion: @escaping ([Book]) -> Void) -> ListenerRegistration {
        return db.collection(collectionName).addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Error listening to books: \(error.localizedDescription)")
                completion([])
                return
            }

            let books = self?.booksFromSnapshot(snapshot) ?? []
            completion(books)
        }
    }

    // Loads books one time. Used for pull to refresh.
    func fetchBooks(completion: @escaping ([Book]) -> Void) {
        db.collection(collectionName).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching books: \(error.localizedDescription)")
                completion([])
                return
            }

            let books = self?.booksFromSnapshot(snapshot) ?? []
            completion(books)
        }
    }

    // Converts Firestore documents into Book objects and sorts newest first.
    private func booksFromSnapshot(_ snapshot: QuerySnapshot?) -> [Book] {
        var books: [Book] = []

        for document in snapshot?.documents ?? [] {
            let data = document.data()

            // Older books may not have createdAt yet.
            var createdAt = Date.distantPast
            if let timestamp = data["createdAt"] as? Timestamp {
                createdAt = timestamp.dateValue()
            }

            let book = Book(
                id: document.documentID,
                title: data["title"] as? String ?? "",
                author: data["author"] as? String ?? "",
                genre: data["genre"] as? String ?? "",
                review: data["review"] as? String ?? "",
                rating: data["rating"] as? Int ?? 0,
                createdAt: createdAt
            )

            books.append(book)
        }

        // Newest books appear at the top.
        books.sort { $0.createdAt > $1.createdAt }
        return books
    }

    // Adds a new book document to Firestore.
    func addBook(title: String,
                 author: String,
                 genre: String,
                 review: String,
                 rating: Int,
                 completion: @escaping (Bool) -> Void) {

        let data: [String: Any] = [
            "title": title,
            "author": author,
            "genre": genre,
            "review": review,
            "rating": rating,
            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection(collectionName).addDocument(data: data) { error in
            if let error = error {
                print("Error adding book: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    // Deletes a book document from Firestore using its id.
    func deleteBook(id: String, completion: @escaping (Bool) -> Void) {
        db.collection(collectionName).document(id).delete { error in
            if let error = error {
                print("Error deleting book: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    // Updates an existing book document in Firestore.
    func updateBook(id: String,
                    title: String,
                    author: String,
                    genre: String,
                    review: String,
                    rating: Int,
                    completion: @escaping (Bool) -> Void) {

        let data: [String: Any] = [
            "title": title,
            "author": author,
            "genre": genre,
            "review": review,
            "rating": rating
        ]

        db.collection(collectionName).document(id).updateData(data) { error in
            if let error = error {
                print("Error updating book: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
