//
//  SavedQuotesViewController.swift
//  Inspirational Bytes
//
//  Created by Joel Gans on 9/16/22.
//

import Foundation
import UIKit
import CoreData

class SavedQuotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var favQuoteText: String = ""
    var author: String = ""
    var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    private var fromFavorites: Bool = false
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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchedResultsController()
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "quoteCells")!
        if fetchedResultsController?.fetchedObjects?.isEmpty == false {
            let currentQuote = fetchedResultsController?.fetchedObjects?[indexPath.row]
            cell.textLabel?.text = currentQuote?.quoteText ?? ""
            cell.detailTextLabel?.text = currentQuote?.authorName ?? ""
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentQuote = fetchedResultsController?.fetchedObjects?[indexPath.row]
        favQuoteText = currentQuote?.quoteText ?? ""
        author = currentQuote?.authorName ?? ""
        performSegue(withIdentifier: "SavedQuotesSegue", sender: AnyObject?.self)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let quoteToDelete = (fetchedResultsController?.object(at: indexPath))! as NSManagedObject
            dataController.viewContext.delete(quoteToDelete)
            setupFetchedResultsController()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        tableView.reloadData()
        try? dataController.viewContext.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SavedQuotesSegue" {
            if let destinationVC = (segue.destination as? QuoteViewController) {
                destinationVC.favQuoteText = favQuoteText
                destinationVC.author = author
                destinationVC.fromFavorites = true
            }
        }
    }
}
