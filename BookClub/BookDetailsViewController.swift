//
//  BookDetailsViewController.swift
//  BookClub
//

import UIKit

class BookDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    // The book selected on the home screen.
    var book: Book?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground

        // Edit button in the navigation bar.
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editTapped)
        )

        styleLabels()
        showBookDetails()
    }

    // Opens the add/edit screen with the current book filled in.
    @objc func editTapped() {
        guard let book = book else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "AddBookViewController") as? AddBookViewController {
            editVC.bookToEdit = book
            navigationController?.pushViewController(editVC, animated: true)
        }
    }

    // Makes the details text look clearer and a bit cuter.
    func styleLabels() {
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        authorLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        authorLabel.textColor = .secondaryLabel

        genreLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        genreLabel.textColor = .systemTeal
        genreLabel.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.12)
        genreLabel.textAlignment = .center
        genreLabel.layer.cornerRadius = 10
        genreLabel.clipsToBounds = true

        reviewLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        reviewLabel.textColor = .label
        reviewLabel.numberOfLines = 0
        reviewLabel.backgroundColor = .secondarySystemGroupedBackground
        reviewLabel.layer.cornerRadius = 14
        reviewLabel.clipsToBounds = true

        ratingLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        ratingLabel.textColor = .systemOrange
    }

    // Fills the labels with the book information.
    func showBookDetails() {
        guard let book = book else { return }

        titleLabel.text = book.title
        authorLabel.text = "by \(book.author)"

        if book.genre.isEmpty {
            genreLabel.text = "  General  "
        } else {
            genreLabel.text = "  \(book.genre)  "
        }

        if book.review.isEmpty {
            reviewLabel.text = "  No review yet.  "
        } else {
            reviewLabel.text = "  \(book.review)  "
        }

        ratingLabel.text = starsText(for: book.rating)
    }

    // Creates a string of stars for the rating.
    func starsText(for rating: Int) -> String {
        if rating <= 0 {
            return ""
        }
        // Use ★ instead of emoji so it shows correctly in the simulator.
        return String(repeating: "★", count: rating)
    }
}
