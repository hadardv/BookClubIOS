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

    // Friendly message when the list is empty.
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No recommendations yet\nTap + to share a book"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Book Club"

        // Large title looks a bit nicer on the home screen.
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        view.backgroundColor = .systemGroupedBackground
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88

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
            self?.updateEmptyState()
        }
    }

    // Shows or hides the empty message.
    func updateEmptyState() {
        if books.isEmpty {
            tableView.backgroundView = emptyLabel
        } else {
            tableView.backgroundView = nil
        }
    }

    // Creates a string of stars for the rating.
    func starsText(for rating: Int) -> String {
        if rating <= 0 {
            return ""
        }
        // Use ★ instead of emoji so it shows correctly in the simulator.
        return String(repeating: "★", count: rating)
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
        cell.ratingLabel.textColor = .systemOrange

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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
}
