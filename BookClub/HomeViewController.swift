//
//  HomeViewController.swift
//  BookClub
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    // Stores all books shown in the table.
    var books: [Book] = []

    // Keeps the Firestore listener so we can stop it later.
    var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Book Recommendations"

        // Connect the table view to this screen.
        tableView.dataSource = self
        tableView.delegate = self

        // Start listening for book updates from Firestore.
        startListeningForBooks()
    }

    // Stops the listener when this screen is removed.
    deinit {
        listener?.remove()
    }

    // Starts a snapshot listener so the table updates automatically.
    func startListeningForBooks() {
        listener = FirestoreManager.shared.listenToBooks { [weak self] books in
            self?.books = books
            self?.tableView.reloadData()
        }
    }

    // Creates a string of stars for the rating.
    func starsText(for rating: Int) -> String {
        if rating <= 0 {
            return ""
        }
        return String(repeating: "⭐", count: rating)
    }

    // Passes the selected book to the details screen.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBookDetails" {
            if let detailsVC = segue.destination as? BookDetailsViewController,
               let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell) {
                detailsVC.book = books[indexPath.row]
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {

    // Number of rows equals number of books.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    // Creates and fills one cell for each book.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath) as! BookTableViewCell

        let book = books[indexPath.row]
        cell.titleLabel.text = book.title
        cell.authorLabel.text = book.author
        cell.ratingLabel.text = starsText(for: book.rating)

        return cell
    }

    // Allows swipe to delete.
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let book = books[indexPath.row]
            FirestoreManager.shared.deleteBook(id: book.id) { success in
                if !success {
                    print("Could not delete book.")
                }
                // The snapshot listener will refresh the table automatically.
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
}
