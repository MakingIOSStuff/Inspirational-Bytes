//
//  QOTDViewController.swift
//  Inspirational Bytes
//
//  Created by Joel Gans on 9/17/22.
//

import Foundation
import CoreData
import UIKit

class QOTDViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    let backgroundImageDownloadQueue = DispatchQueue(label: "com.vt.quote_download_queue")
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var QOTDLabel: UILabel!
    @IBOutlet weak var QOTDAuthorLabel: UILabel!
    @IBOutlet weak var favButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var getQuoteButton: UIButton!
    
    var savedQuotes: SavedQuotes?
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
        setQOTD()
    }
    
    func setQOTD () {
        let favQuote = SavedQuotes(context: dataController.viewContext)
        NetworkManager.getQOTD() { quoteResponse, error in
            debugPrint("\(String(describing: quoteResponse)) was returned")
            if error == nil {
                let responseText = quoteResponse?[0]
                self.QOTDLabel.text = responseText?.text
                self.QOTDAuthorLabel.text = responseText?.author
                favQuote.quoteText = responseText?.text
                favQuote.authorName = responseText?.author
            }
            self.activityIndicator.stopAnimating()
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
        favButton.customView?.isHidden = false
        shareButton.customView?.isHidden = false
        getQuoteButton.isHidden = false
        
        return shareQuote
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        let shareQuote = createShareQuote()
        let controller = UIActivityViewController(activityItems: [shareQuote], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func saveToFavButton(_ sender: Any) {
        try? dataController.viewContext.save()
        debugPrint("saving quote items to savedquotes")
    }
    
    @IBAction func GetQuotesButton(_ sender: Any) {
        
        }
}


