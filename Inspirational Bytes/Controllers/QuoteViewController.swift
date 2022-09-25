//
//  QuoteViewController.swift
//  Inspirational Bytes
//
//  Created by Joel Gans on 9/11/22.
//

import Foundation
import UIKit
import CoreData

class QuoteViewController: UIViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var QuoteLabel: UILabel!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var favButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var refreshQuoteButton: UIButton!
    
    let backgroundImageDownloadQueue = DispatchQueue(label: "com.vt.quote_download_queue")
    var randomQuotes = [QuoteResponse]()
    var favQuoteText: String = ""
    var author: String = ""
    var favQuote = favoriteQuotes(quoteText: "" , authorName: "")
    var fromFavorites: Bool = false
    var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    var savedQuotes: SavedQuotes?
    var fetchedResultsController: NSFetchedResultsController<SavedQuotes>?
    
    func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<SavedQuotes> = SavedQuotes.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "authorName", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    
    override func viewDidLoad() {
        setupFetchedResultsController()
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }

    override func viewWillAppear(_ animated: Bool) {
        if fromFavorites == true {
            QuoteLabel.text = favQuoteText
            AuthorLabel.text = author
            favButton.isEnabled = false
            favButton.customView?.isHidden = true
            refreshQuoteButton.isHidden = true
            activityIndicator.stopAnimating()
        } else {
            setSavedQuote()
        }
    }
    
    func setSavedQuote() {
        if randomQuotes.isEmpty == true {
            NetworkManager.getQuotes { quoteResponse, error in
                if let quoteResponse = quoteResponse {
                    self.randomQuotes.append(contentsOf: quoteResponse)
                    let index = Int.random(in: 0...(quoteResponse.count - 1))
                    let currentQuote = quoteResponse[index]
                    self.QuoteLabel.text = "\"\(currentQuote.text)\""
                    self.AuthorLabel.text = "-\(currentQuote.author)"
                    self.favQuote.quoteText = "\"\(currentQuote.text)\""
                    self.favQuote.authorName = "-\(currentQuote.author)"
                    self.activityIndicator.stopAnimating()
                    }
                }
        } else {
            let index = Int.random(in: 0...(randomQuotes.count - 1))
            let currentQuote = randomQuotes[index]
            QuoteLabel.text = "\"\(currentQuote.text)\""
            AuthorLabel.text = "-\(currentQuote.author)"
            favQuote.quoteText = "\"\(currentQuote.text)\""
            favQuote.authorName = "-\(currentQuote.author)"
            activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func NewQuoteButton(_ sender: Any) {
        activityIndicator.startAnimating()
        setSavedQuote()
        favButton.isEnabled = true
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    func createShareQuote() -> UIImage {
        backButton.customView?.isHidden = true
        favButton.customView?.isHidden = true
        shareButton.customView?.isHidden = true
        refreshQuoteButton.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let shareQuote: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        if fromFavorites == false {
            favButton.customView?.isHidden = false
            refreshQuoteButton.isHidden = false
        }
        backButton.customView?.isHidden = false
        shareButton.customView?.isHidden = false
        return shareQuote
    }
    
    @IBAction func saveToFav(_ sender: UIButton) {
        let quoteForSave = SavedQuotes(context: dataController.viewContext)
        quoteForSave.quoteText = favQuote.quoteText
        quoteForSave.authorName = favQuote.authorName
        try? dataController.viewContext.save()
        favButton.isEnabled = false
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        let shareQuote = createShareQuote()
        let controller = UIActivityViewController(activityItems: [shareQuote], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }
    
    //MARK: Display error
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}

