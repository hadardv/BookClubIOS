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
        title = "Book Details"
        showBookDetails()
    }

    // Fills the labels with the book information.
    func showBookDetails() {
        guard let book = book else { return }

        titleLabel.text = book.title
        authorLabel.text = book.author
        genreLabel.text = "Genre: \(book.genre)"
        reviewLabel.text = book.review
        ratingLabel.text = "Rating: \(starsText(for: book.rating))"
    }

    // Creates a string of stars for the rating.
    func starsText(for rating: Int) -> String {
        if rating <= 0 {
            return ""
        }
        return String(repeating: "⭐", count: rating)
    }
}
