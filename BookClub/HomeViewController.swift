//
//  HomeViewController.swift
//  BookClub

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Book Recommendations"
    }
}
