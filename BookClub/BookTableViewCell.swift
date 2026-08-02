//
//  BookTableViewCell.swift
//  BookClub
//

import UIKit

class BookTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    // Soft card behind the book info.
    let cardView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardLook()
    }

    // Makes each row look like a soft rounded card.
    func setupCardLook() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        cardView.backgroundColor = .secondarySystemGroupedBackground
        cardView.layer.cornerRadius = 14
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Put the card behind the labels.
        contentView.insertSubview(cardView, at: 0)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        authorLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        authorLabel.textColor = .secondaryLabel
        ratingLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        ratingLabel.textColor = .systemOrange
    }
}
