# BookClub

An iOS app for sharing book recommendations.
All users see the same list because the data is stored in Firebase Firestore.
There is no login.

## Features

- View all book recommendations
- Add a new recommendation
- Open a book to see its details
- Swipe to delete a recommendation
- Supports Light Mode and Dark Mode

## Tech

- UIKit
- Storyboards
- UITableView
- Navigation Controller
- Firebase Firestore

## Project Structure

- `Book.swift` - book data model
- `FirestoreManager.swift` - Firestore read, write, and delete
- `HomeViewController.swift` - list of books
- `BookDetailsViewController.swift` - book details screen
- `AddBookViewController.swift` - add recommendation screen
- `BookTableViewCell.swift` - custom table view cell
- `Main.storyboard` - app screens and navigation
- `GoogleService-Info.plist` - Firebase configuration

## How to Run

1. Open `BookClub.xcodeproj` in Xcode.
2. Wait for the Firebase package to finish resolving if needed.
3. Choose a simulator or your iPhone.
4. Press Run.

Make sure `GoogleService-Info.plist` is included in the BookClub target.

## Firebase Setup

1. Create a Firebase project.
2. Add an iOS app with bundle ID `com.hadardv.BookClub`.
3. Download `GoogleService-Info.plist` and add it to the BookClub folder in Xcode.
4. Enable Cloud Firestore and start it in test mode.
5. In Xcode, add the Firebase iOS SDK package:
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Product: `FirebaseFirestore`

Books are stored in the `books` collection with these fields:

- title (String)
- author (String)
- genre (String)
- review (String)
- rating (Int)
