//
//  BookTableViewCell.swift
//  BookClub
//

import UIKit

class BookTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
