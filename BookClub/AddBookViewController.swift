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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Book"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        styleForm()
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

        // Save the new book to Firestore.
        FirestoreManager.shared.addBook(
            title: titleText,
            author: authorText,
            genre: genreText,
            review: reviewText,
            rating: rating
        ) { [weak self] success in
            if success {
                // Go back to the home screen.
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.showAlert(message: "Could not save the book. Please try again.")
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
