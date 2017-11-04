//
//  PlaylistsViewController.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/7/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer
import NVActivityIndicatorView
import Crashlytics

class PlaylistsViewController: UIViewController, AVAudioPlayerDelegate, UIToolbarDelegate
{
    // MARK: - Tableview
    @IBOutlet weak var tableView: UITableView!
    
    var currentPlaylists = CoreDataHelper.retrievePlaylists()
    
    var currentRow: Int?
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
        
        // get rid of extra separators by adding a view below
        self.tableView.tableFooterView = UIView()
        // Swift 4 updated
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 20)!]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPlaylists = CoreDataHelper.retrievePlaylists()
        tableView.reloadData()
        
        if SongPlayerHelper.isSongLoaded
        {
//            // Updates the slider position regularly at the specified interval
//            Timer.scheduledTimer(timeInterval: 0.05, target: self,  selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showPlaylistDetail"
        {
            let destinationVC = (segue.destination as? PlaylistDetailViewController)
            self.currentRow = tableView.indexPathForSelectedRow?.row
            destinationVC?.currentPlaylist = currentPlaylists[currentRow!]
        }
        else if segue.identifier == "addPlaylist"
        {
            let destinationVC = (segue.destination as? PlaylistDetailViewController)
            let newPlaylist = CoreDataHelper.newPlaylist()
            CoreDataHelper.savePlaylist()
            destinationVC?.currentPlaylist = newPlaylist
            Answers.logCustomEvent(withName: "Created New Playlist", customAttributes: nil)
        }
    }

    // Convert to minutes and seconds
    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}


extension PlaylistsViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return currentPlaylists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell") as! PlaylistsTableViewCell
        let text = currentPlaylists[indexPath.row].name ?? ""
        cell.playlistNameLabel.text = text
        return cell
    }
    
    // Display playlist detail after selecting playlist
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    // The height of the songs cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55
    }
    
    // Deleting playlists
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (currentPlaylists[indexPath.row].playlistSongs?.count)! > 0
            {
                // display action sheet to delete playlist
                // warning you are about to delete a playlist containing songs are you sure you want to continue?
                
            }
            CoreDataHelper.deletePlaylist(playlist: currentPlaylists[indexPath.row])
            currentPlaylists = CoreDataHelper.retrievePlaylists()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                tableView.reloadData()
            })
        }
    }
    
    
}
