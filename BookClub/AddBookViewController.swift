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
        setupKeyboardDismiss()
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

        // Shows a Done button on the keyboard.
        textField.returnKeyType = .done
        textField.delegate = self
    }

    // Lets the user dismiss the keyboard easily.
    func setupKeyboardDismiss() {
        // Tap anywhere on the screen to close the keyboard.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        // Add a Done button above the keyboard for the review box.
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: .done,
                                         target: self,
                                         action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        reviewTextView.inputAccessoryView = toolbar
    }

    // Hides the keyboard.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // Shows a loading state on the Save button while Firestore works.
    func setSaving(_ isSaving: Bool) {
        saveButton.isEnabled = !isSaving

        var buttonConfig = saveButton.configuration ?? UIButton.Configuration.filled()
        buttonConfig.showsActivityIndicator = isSaving

        if isSaving {
            buttonConfig.title = "Saving..."
        } else if bookToEdit != nil {
            buttonConfig.title = "Save Changes"
        } else {
            buttonConfig.title = "Save Recommendation"
        }

        saveButton.configuration = buttonConfig
    }

    // Called when the Save button is pressed.
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dismissKeyboard()

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

        setSaving(true)

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
                DispatchQueue.main.async {
                    self?.setSaving(false)

                    if success {
                        // Go back to the home list after editing.
                        self?.navigationController?.popToRootViewController(animated: true)
                    } else {
                        self?.showAlert(message: "Could not update the book. Please try again.")
                    }
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
                DispatchQueue.main.async {
                    self?.setSaving(false)

                    if success {
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self?.showAlert(message: "Could not save the book. Please try again.")
                    }
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

// MARK: - UITextFieldDelegate
extension AddBookViewController: UITextFieldDelegate {

    // Closes the keyboard when Done is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
