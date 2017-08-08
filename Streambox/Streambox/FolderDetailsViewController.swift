//
//  FolderDetailsViewController.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/12/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

class FolderDetailsViewController: UIViewController {
    var items = [Item]()
    var parentItem: Item?
    var indexPath: IndexPath?
    var isCellSelected = [Bool]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView() // get rid of extra separators by adding a view below
        tableView.delegate = self
        tableView.dataSource = self
        self.title = parentItem!.name
        
        self.initializeItems(rootPath: (parentItem?.filePath ?? "")!)
        self.tableView.reloadData()

    }
    
    func initializeItems(rootPath: String) {
        // folder objects
        DropboxHelper.getItems(directory: rootPath, onCompletion: { (retrievedItems) in
            if let retrievedItems = retrievedItems {
                self.items = retrievedItems
                self.tableView.reloadData()
            }
        })
    }
}


extension FolderDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell") as! FolderDetailsTableViewCell
        let text = items[indexPath.row].name
        cell.itemNameLabel.text = text
        cell.row = indexPath.row
        cell.delegate = self
        cell.isCheckmarked = items[indexPath.row].isSelected
        cell.correspondingItem = items[indexPath.row]
        cell.itemNameLabel.font = UIFont.systemFont(ofSize: 15.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = items[indexPath.item]
        let fileName = items[indexPath.item].name
        print(fileName)
        
        // check if selected file contains files
        file.hasSubdirectory(filePath: file.filePath, onCompletion: { (containsFolders) in
            if containsFolders != nil {
                self.presentNewViewController(folder: file, indexPath: indexPath)
            }
        })
        
        
        
        
    }
    
    // push new view controller based upon the folder the user selects
    func presentNewViewController(folder: Item, indexPath: IndexPath) {
        // Present view controller
        
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! FolderDetailsViewController
        destinationVC.parentItem = folder
        destinationVC.indexPath = indexPath
        //        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SelectFoldersID") as! SelectFoldersViewController
        //        controller.title = folder.name
        //        controller.initializeFolders(rootPath: folder.rootDirectory)
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }

}


extension FolderDetailsViewController: FolderDetailsTableViewCellProtocol {
    func updateSelectedArray(for row: Int, to value: Bool) {
        items[row].isSelected = value
    }
}
