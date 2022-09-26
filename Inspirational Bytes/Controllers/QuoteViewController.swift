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
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var favButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var refreshQuoteButton: UIButton!
    
    let backgroundImageDownloadQueue = DispatchQueue(label: "com.vt.quote_download_queue")
    var randomQuotes = [QuoteResponse]()
    var favQuoteText: String = ""
    var author: String = ""
    var quoteText: String = ""
    var quoteToDelete: NSManagedObject!
    var savedToFavs: Bool = false
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
            quoteLabel.text = favQuoteText
            authorLabel.text = author
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
                guard error == nil else {
                    self.activityIndicator.stopAnimating()
                    self.showError(message: error!.localizedDescription)
                    return
                }
                if let quoteResponse = quoteResponse {
                    self.randomQuotes.append(contentsOf: quoteResponse)
                    let index = Int.random(in: 0...(quoteResponse.count - 1))
                    let currentQuote = quoteResponse[index]
                    self.quoteLabel.text = "\"\(currentQuote.text)\""
                    self.authorLabel.text = "-\(currentQuote.author)"
                    self.favQuote.quoteText = "\"\(currentQuote.text)\""
                    self.favQuote.authorName = "-\(currentQuote.author)"
                    self.quoteText = currentQuote.text
                    self.activityIndicator.stopAnimating()
                }
                self.activityIndicator.stopAnimating()
                }
        } else {
            let index = Int.random(in: 0...(randomQuotes.count - 1))
            let currentQuote = randomQuotes[index]
            quoteLabel.text = "\"\(currentQuote.text)\""
            authorLabel.text = "-\(currentQuote.author)"
            favQuote.quoteText = "\"\(currentQuote.text)\""
            favQuote.authorName = "-\(currentQuote.author)"
            quoteText = currentQuote.text
            activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func NewQuoteButton(_ sender: Any) {
        activityIndicator.startAnimating()
        setSavedQuote()
        setFavButton()
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true)
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
    
    func setFavButton() {
        let fetchRequest:NSFetchRequest<SavedQuotes> = SavedQuotes.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "authorName", ascending: false)
                fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "quoteText = %@", "\"\(quoteText)\"")

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            debugPrint("The fetch could not be performed: \(error.localizedDescription)")
        }
        if fetchedResultsController?.fetchedObjects?.isEmpty == true {
            savedToFavs = false
            favButton.customView?.tintColor = .blue
        } else {
            quoteToDelete = fetchedResultsController?.fetchedObjects?[0]
            savedToFavs = true
            favButton.customView?.tintColor = .magenta
        }
    }
    
    @IBAction func saveToFav(_ sender: UIButton) {
        if savedToFavs == false {
            let quoteForSave = SavedQuotes(context: dataController.viewContext)
            quoteForSave.quoteText = favQuote.quoteText
            quoteForSave.authorName = favQuote.authorName
        } else {
            _ = SavedQuotes(context: dataController.viewContext)
            dataController.viewContext.delete(quoteToDelete)
        }
        try? dataController.viewContext.save()
        setFavButton()
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        let shareQuote = createShareQuote()
        let controller = UIActivityViewController(activityItems: [shareQuote], applicationActivities: nil)
        if UITraitCollection.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.sourceView = sender
        }
        present(controller, animated: true, completion: nil)
    }
    
    //MARK: Display error
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
}

