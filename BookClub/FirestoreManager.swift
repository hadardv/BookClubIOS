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
        return db.collection(collectionName).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to books: \(error.localizedDescription)")
                completion([])
                return
            }

            var books: [Book] = []

            // Loop through every document in Firestore.
            for document in snapshot?.documents ?? [] {
                let data = document.data()

                let book = Book(
                    id: document.documentID,
                    title: data["title"] as? String ?? "",
                    author: data["author"] as? String ?? "",
                    genre: data["genre"] as? String ?? "",
                    review: data["review"] as? String ?? "",
                    rating: data["rating"] as? Int ?? 0
                )

                books.append(book)
            }

            completion(books)
        }
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
            "rating": rating
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
