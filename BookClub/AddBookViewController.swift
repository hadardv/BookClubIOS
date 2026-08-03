//
//  AddBookViewController.swift
//  BookClub
//

import UIKit

class AddBookViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var ratingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!

    // If this is set, the screen is used to edit an existing book.
    var bookToEdit: Book?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        styleForm()
        setupForAddOrEdit()
    }

    // Changes the title and fills the form when editing.
    func setupForAddOrEdit() {
        if let book = bookToEdit {
            title = "Edit Book"
            titleTextField.text = book.title
            authorTextField.text = book.author
            genreTextField.text = book.genre
            reviewTextView.text = book.review

            // Rating is 1...5, but segment indexes are 0...4.
            let ratingIndex = max(0, min(4, book.rating - 1))
            ratingSegmentedControl.selectedSegmentIndex = ratingIndex

            var buttonConfig = saveButton.configuration ?? UIButton.Configuration.filled()
            buttonConfig.title = "Save Changes"
            saveButton.configuration = buttonConfig
        } else {
            title = "New Book"
        }
    }

    // Softens the form so it feels more friendly.
    func styleForm() {
        styleTextField(titleTextField, placeholder: "Book title")
        styleTextField(authorTextField, placeholder: "Author")
        styleTextField(genreTextField, placeholder: "Genre (optional)")

        reviewTextView.backgroundColor = .secondarySystemGroupedBackground
        reviewTextView.textColor = .label
        reviewTextView.font = UIFont.systemFont(ofSize: 16)
        reviewTextView.layer.cornerRadius = 12
        reviewTextView.clipsToBounds = true
        reviewTextView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)

        ratingSegmentedControl.selectedSegmentTintColor = .systemTeal

        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = "Save Recommendation"
        buttonConfig.baseBackgroundColor = .systemTeal
        buttonConfig.baseForegroundColor = .white
        buttonConfig.cornerStyle = .large
        saveButton.configuration = buttonConfig
    }

    // Shared look for all text fields.
    func styleTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
    }

    // Called when the Save button is pressed.
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let titleText = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let authorText = authorTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let genreText = genreTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let reviewText = reviewTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Rating segments are 0...4, so add 1 to get 1...5.
        let rating = ratingSegmentedControl.selectedSegmentIndex + 1

        // Title and author are required.
        if titleText.isEmpty || authorText.isEmpty {
            showAlert(message: "Please enter a title and an author.")
            return
        }

        if let book = bookToEdit {
            // Update an existing book.
            FirestoreManager.shared.updateBook(
                id: book.id,
                title: titleText,
                author: authorText,
                genre: genreText,
                review: reviewText,
                rating: rating
            ) { [weak self] success in
                if success {
                    // Go back to the home list after editing.
                    self?.navigationController?.popToRootViewController(animated: true)
                } else {
                    self?.showAlert(message: "Could not update the book. Please try again.")
                }
            }
        } else {
            // Save a new book to Firestore.
            FirestoreManager.shared.addBook(
                title: titleText,
                author: authorText,
                genre: genreText,
                review: reviewText,
                rating: rating
            ) { [weak self] success in
                if success {
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.showAlert(message: "Could not save the book. Please try again.")
                }
            }
        }
    }

    // Shows a simple alert to the user.
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Oops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
