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

class DropboxViewController: UIViewController, NVActivityIndicatorViewable
{
    // MARK: - Properties
    var items = [Item]() // the items displayed in the table view
    var parentItem: Item?
    var currentDirectory: String = "" // the path of the current instantiated dropbox view controller
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    override func viewDidLoad()
    {
//        CoreDataHelper.deleteAllUsers()
        // Update the title
        self.navigationItem.title = parentItem?.name ?? "Dropbox"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Swift 4 updated
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 20)!]
        
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Lato-Light", size: 18)!], for: .normal)
        
        // Update navigation bar back button
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Lato-Light", size: 18)!], for: .normal)
        
        
        
        
        
        super.viewDidLoad()
        
        // Get rid of extra separators by adding a view below
        self.tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // show activity indicator
        startAnimating(CGSize(width: 50, height: 50), type: .ballClipRotate)
        
        // Get the items for the given path
        DropboxHelper.getItems(directory: parentItem?.itemMetadata.pathLower ?? "") { (items) in
            self.items = items!
            self.tableView.reloadData()
            
            // hide activity indicator
            self.stopAnimating()
        }
        
    }

    
}

// TableViewDataSource and TableViewDelegate
extension DropboxViewController: UITableViewDataSource, UITableViewDelegate
{
    // number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    // Populate tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropboxTableViewCell") as! DropboxTableViewCell
        let item = items[indexPath.row]
        let filePath = item.itemMetadata.pathDisplay
        cell.itemOfThisCell = item
        cell.itemNameLabel.text = item.name
        
        // Check if selected item contains items. If so, show folder chevron
        DropboxHelper.hasSubdirectory(id: filePath ?? "", onCompletion: { (containsFiles) in
            if containsFiles != nil
            {
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
        })
        return cell
        
    }
    
    
    // Row tapped, present new view controller if the entry is a folder.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let item = items[indexPath.item]
        let filePath = item.itemMetadata.pathDisplay
        
        // Check if selected item contains items. If so, present new view controller with folder as the title
        DropboxHelper.hasSubdirectory(id: filePath ?? "", onCompletion: { (containsFiles) in
            if containsFiles != nil
            {
                let selectedCell = tableView.cellForRow(at: indexPath)
                
                // present the new view controller
                self.presentNewViewController(item: item, selectedCell: selectedCell as! DropboxTableViewCell)
            }
        })
    }
    
    // The height of the cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55
    }
    
    
    
    // push new view controller based upon the folder the user selects
    func presentNewViewController(item: Item, selectedCell: DropboxTableViewCell)
    {
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "DropboxViewController") as! DropboxViewController
        destinationVC.parentItem = item
        destinationVC.currentDirectory = currentDirectory // not sure if this is right
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    
}


