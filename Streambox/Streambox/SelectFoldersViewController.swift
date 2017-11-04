//
//  SelectFoldersViewController.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/6/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import Foundation
import UIKit
import SwiftyDropbox
import NVActivityIndicatorView
import Crashlytics

class SelectFoldersViewController: UIViewController, NVActivityIndicatorViewable, SelectEntryProtocol
{
    // MARK: - Properties
    
    // Items array
    var items = [Item]()
    
    // The entries to be initialized.  This gets modified when a user selects/unselects items
    var entriesToBeInitialized = [Entry]()
    var parentEntry: Entry?
    var indexPath: IndexPath?
    var isChild = false
    var entries: [Entry]?
    var parentWasInitialized = false
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    
    
    // MARK: - VC Lifecycle
    override func viewDidLoad()
    {
        // Update the title
        self.navigationItem.title = parentEntry?.name ?? "Select Files"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Swift 4 updated
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 20)!]
        
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Lato-Light", size: 18)!], for: .normal)
        
        // Update navigation bar back button
        // Swift 4 updated
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Lato-Light", size: 18)!], for: .normal)
        
        
        
        
        
        super.viewDidLoad()
        
        // Get rid of extra separators by adding a view below
        self.tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem?.style = .done
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // show activity indicator
        startAnimating(CGSize(width: 50, height: 50), type: .ballClipRotate)
        
        // Get the entries for the given path
        DropboxHelper.getItemsAsMetadata(directory: parentEntry?.entryMetadata.pathLower ?? "") { (entries) in
            self.entries = entries
            self.tableView.reloadData()
            
            // hide activity indicator
            self.stopAnimating()
        }
        
    }
    
    // Initialize the items
    func initializeItems(rootPath: String)
    {
        DropboxHelper.getItems(directory: rootPath, onCompletion: { (retrievedItems) in
            if let retrievedItems = retrievedItems
            {
                for item in retrievedItems
                {
                    self.items.append(item)
                }
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
    }
    
    // Done button tapped
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "done"
        {
            let songsViewController = segue.destination as! SongsViewController
            
            // initialize entries
            for entry in entriesToBeInitialized {
                let item = Item(name: entry.name, rootDirectory: parentEntry?.entryMetadata.pathLower ?? "", id: entry.id)
                item.isSelected = entry.isSelected
                self.items.append(item)
            }
            
            songsViewController.items = items
            
            Answers.logCustomEvent(withName: "Imported Songs from Dropbox", customAttributes: nil)
            
        }
    }
    
    // Done tapped
    @IBAction func onDone(_ sender: Any) {
        //initialize entries
        for entry in entriesToBeInitialized
        {
            let item = Item(name: entry.name, rootDirectory: parentEntry?.entryMetadata.pathLower ?? "", id: entry.id)
            self.items.append(item)
        }
    }

    
}

// TableViewDataSource and TableViewDelegate
extension SelectFoldersViewController: UITableViewDataSource, UITableViewDelegate
{
    // number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return entries?.count ?? 0
        //return items.count
    }
    
    // Populate tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell") as! FoldersTableViewCell
        
        cell.delegate = self
        let entry = entries?[indexPath.row]
        let filePath = entry?.entryMetadata.pathDisplay
        
        cell.entryOfThisCell = entry!
        
        cell.itemNameLabel.text = entry?.name
        
        // Check if selected item contains items. If so, show folder chevron
        DropboxHelper.hasSubdirectory(filePath: filePath ?? "", onCompletion: { (containsFiles) in
            if containsFiles != nil
            {
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
        })
        
        // handle checkbox image
        if parentWasInitialized == true {
            cell.self.checkbox.setImage(UIImage(named: "selected"), for: .normal)
            cell.self.checkbox.isSelected = true
            cell.entryOfThisCell?.isSelected = true
            cell.isCellSelected = true
        } else {
            cell.self.checkbox.setImage(UIImage(named: "unselected"), for: .normal)
            cell.self.checkbox.isSelected = false
            cell.self.entryOfThisCell?.isSelected = false
            cell.isCellSelected = false
        }
        
        return cell
    }
    
    
    // Row tapped, present new view controller if the entry is a folder.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let entry = entries?[indexPath.item]
        let filePath = entry?.entryMetadata.pathDisplay
        
        // Check if selected item contains items. If so, present new view controller with folder as the title
        DropboxHelper.hasSubdirectory(filePath: filePath ?? "", onCompletion: { (containsFiles) in
            if containsFiles != nil
            {
                
                let selectedCell = tableView.cellForRow(at: indexPath)
                
                // present the new view controller
                self.presentNewViewController(entry: entry!, selectedCell: selectedCell as! FoldersTableViewCell)
                
                
            }
        })
    }
    
    // The height of the songs cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55
    }
    
    // From the Select Entry Protocol
    // Called when the user selects an entry.  When selected, adds the entry to entriesToBeInitialized array.  When unselected, removes entry from the array.
    func whenEntryIsSelected(cell: FoldersTableViewCell)
    {
        let entryToInitialize = cell.entryOfThisCell
        
        if let indexToBeDeleted = entriesToBeInitialized.index(where: { $0.name == entryToInitialize?.name }) {
            entriesToBeInitialized.remove(at: indexToBeDeleted)
        } else {
            entriesToBeInitialized.append(entryToInitialize!)
        }
        
        updateCellUI(cell: cell)
    }
    
    // Update the checkbox's image
    func updateCellUI(cell: FoldersTableViewCell)
    {
        if cell.self.checkbox.isSelected {
            cell.self.checkbox.setImage(UIImage(named: "unselected"), for: .normal)
            cell.self.checkbox.isSelected = false
            cell.self.isSelected = false
            cell.isCellSelected = false
        } else {
            cell.self.checkbox.setImage(UIImage(named: "selected"), for: .normal)
            cell.self.checkbox.isSelected = true
            cell.self.isSelected = true
            cell.isCellSelected = true
            
        }
    }
    
    
    
    // push new view controller based upon the folder the user selects
    func presentNewViewController(entry: Entry, selectedCell: FoldersTableViewCell)
    {
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectFoldersVC") as! SelectFoldersViewController
        destinationVC.parentEntry = entry
        destinationVC.indexPath = indexPath
        destinationVC.isChild = true
        
        if selectedCell.checkbox.isSelected
        {
            destinationVC.parentWasInitialized = true
        }
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    
}


