//
//  QOTDViewController.swift
//  Inspirational Bytes
//
//  Created by Joel Gans on 9/17/22.
//

import Foundation
import CoreData
import UIKit

class QOTDViewController: UIViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate {
    
    let backgroundImageDownloadQueue = DispatchQueue(label: "com.vt.quote_download_queue")
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var qotdLabel: UILabel!
    @IBOutlet weak var qotdAuthorLabel: UILabel!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var favButton: UIBarButtonItem!
    @IBOutlet weak var getQuoteButton: UIButton!
    
    var favQuote = favoriteQuotes(quoteText: "" , authorName: "")
    var savedQuotes: SavedQuotes?
    var quoteText: String = ""
//    var quoteToDelete: implement var to pass to button for delete
    var savedToFavs: Bool = false
    var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
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
        activityIndicator.startAnimating()
        super.viewDidLoad()
        self.setQOTD()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func setQOTD () {
        NetworkManager.getQOTD() { quoteResponse, error in
            guard error == nil else {
                self.activityIndicator.stopAnimating()
                self.showError(message: error!.localizedDescription)
                return
            }
            if let quoteResponse = quoteResponse {
                let responseText = quoteResponse[0]
                self.qotdLabel.text = "\"\(responseText.text)\""
                self.qotdAuthorLabel.text = "-\(responseText.author)"
                self.favQuote.quoteText = "\"\(responseText.text)\""
                self.favQuote.authorName = "-\(responseText.author)"
                self.quoteText = responseText.text
            }
            self.activityIndicator.stopAnimating()
            self.setFavButton()
        }
    }
    
    func createShareQuote() -> UIImage {
        favButton.customView?.isHidden = true
        shareButton.customView?.isHidden = true
        getQuoteButton.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let shareQuote: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        shareButton.customView?.isHidden = false
        favButton.customView?.isHidden = false
        getQuoteButton.isHidden = false
        
        return shareQuote
    }
    
    func setFavButton() {
        let fetchRequest:NSFetchRequest<SavedQuotes> = SavedQuotes.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "authorName", ascending: false)
                fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        fetchRequest.predicate = NSPredicate(format: "quoteText = %@", quoteText)
        debugPrint("fetch returned: \(String(describing: fetchedResultsController?.fetchedObjects))")
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            debugPrint("The fetch could not be performed: \(error.localizedDescription)")
        }
        if fetchedResultsController?.fetchedObjects?.isEmpty == true {
            savedToFavs = false
            favButton.tintColor = .blue
        } else {
            //pass back index for delete if button is pressed
            savedToFavs = true
            favButton.tintColor = .systemPink
        }
    }
    
    @IBAction func saveToFav(_ sender: UIButton) {
        if savedToFavs == false {
        let quoteForSave = SavedQuotes(context: dataController.viewContext)
        quoteForSave.quoteText = favQuote.quoteText
        quoteForSave.authorName = favQuote.authorName
        } else {
//            dataController.viewContext.delete(quoteToDelete) FIX THE VAR
            setupFetchedResultsController()
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
    
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
    
    
    @IBAction func GetQuotesButton(_ sender: UIButton) {
        }
}


