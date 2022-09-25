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
    @IBOutlet weak var shareButton: UIButton!
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
        NetworkManager.getQOTD() { quoteResponse, error in
            debugPrint("\(String(describing: quoteResponse)) was returned")
            if let quoteResponse = quoteResponse {
                let responseText = quoteResponse[0]
                self.QOTDLabel.text = "\"\(responseText.text)\""
                self.QOTDAuthorLabel.text = "-\(responseText.author)"
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    func createShareQuote() -> UIImage {
        shareButton.isHidden = true
        getQuoteButton.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let shareQuote: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        shareButton.isHidden = false
        getQuoteButton.isHidden = false
        
        return shareQuote
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        let shareQuote = createShareQuote()
        let controller = UIActivityViewController(activityItems: [shareQuote], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func GetQuotesButton(_ sender: UIButton) {
        
        }
}


