//
//  AddSongsToPlaylistViewController.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/10/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics

class AddSongsToPlaylistViewController: UIViewController, UISearchBarDelegate, SelectSongDelegate
{
    
    // MARK: - Properties
    var filteredSongs = [Song]()
    
    // The songs to add to the playlist
    var selectedSongs = [Song]()
    
    // MARK: - Navigation Items
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - Search Bar
    @IBOutlet weak var searchBar: UISearchBar!
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Table View
    @IBOutlet weak var tableView: UITableView!
    
    // Playlist
    var currentPlaylist: Playlist?
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredSongs = songs
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        // get rid of extra separators by adding a view below
        self.tableView.tableFooterView = UIView()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        // Swift 4 updated
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 20)!]
        // Swift 4 updated
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Lato-Light", size: 18)!], for: .normal)
        
        
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "unwindToPlaylistDetail"
        {
            for song in selectedSongs
            {
                let mutableItems = (currentPlaylist?.playlistSongs?.mutableCopy()) as! NSMutableOrderedSet
                mutableItems.add(song)
                currentPlaylist?.playlistSongs = mutableItems.copy() as? NSOrderedSet
            }
        }
    }
    
    
    
}

extension AddSongsToPlaylistViewController: UITableViewDataSource, UITableViewDelegate
{
    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSongs.count
    }
    
    // Populate table view with the songs
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddSongToPlaylistCell") as! AddSongsToPlaylistTableViewCell
        let text = filteredSongs[indexPath.row].title
        cell.songOfThisCell = filteredSongs[indexPath.row]
        cell.delegate = self
        cell.songTitleLabel.text = text
        cell.songTitleLabel.font = UIFont.systemFont(ofSize: 15.0)
        cell.songTitleLabel.numberOfLines = 1
        return cell
        
    }
    
    // The height of the songs cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55
    }
    
    // From the SelectSongProtocol
    // Called when the user selects a song.  When selected, adds song to selected songs array.  When unselected, removes song from the array.
    func whenSongIsSelected(cell: AddSongsToPlaylistTableViewCell)
    {
        let songToAdd = cell.songOfThisCell!
        
        if let indexToBeDeleted = selectedSongs.index(where: { $0.title == songToAdd.title }) {
            selectedSongs.remove(at: indexToBeDeleted)
        } else {
            selectedSongs.append(songToAdd)
        }
        
        if cell.checkbox.isSelected == true
        {
            cell.checkbox.setImage(UIImage(named: "unselected"), for: .normal)
            cell.checkbox.isSelected = false
        } else
        {
            cell.checkbox.setImage(UIImage(named: "selected"), for: .normal)
            cell.checkbox.isSelected = true
        }
    }
    
    // Utility function for implementing search functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {        
        filteredSongs = searchText.isEmpty ? songs : songs.filter { (item: Song) -> Bool in
            return item.title?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tableView.reloadData()
    }
}
