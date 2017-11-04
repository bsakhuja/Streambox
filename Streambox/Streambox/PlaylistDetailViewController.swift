//
//  NewPlaylistViewController.swift
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

class PlaylistDetailViewController: UIViewController, AVAudioPlayerDelegate, UIToolbarDelegate
{
    
    // MARK: - Properties
    @IBOutlet weak var addMusicButton: UIButton!
    @IBOutlet weak var playlistNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // Utility variables for ensuring that the user can't download a song that they're already playing
    var indexPathOfFirstSong: IndexPath?
    var selectedRow: IndexPath?
    var previousRow: IndexPath?
    
    // Variables for song controls
    var previousIndexPath: IndexPath?
    var nextIndexPath: IndexPath?
    
    var currentPlaylist: Playlist?
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addMusicButton.layer.cornerRadius = 6
        
        // get rid of extra separators by adding a view below
        self.tableView.tableFooterView = UIView()
        
        self.navigationItem.title = (currentPlaylist?.name) ?? "New Playlist"
        self.playlistNameTextField.text = (currentPlaylist?.name) ?? ""
        self.navigationController?.navigationBar.tintColor = UIColor.white
        // Swift 4 updated
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 20)!]
        // Swift 4 updated
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Lato-Light", size: 18)!], for: .normal)
        
        
        self.tableView.reloadData()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if SongPlayerHelper.isSongLoaded
        {
            // Updates the slider position regularly at the specified interval
            Timer.scheduledTimer(timeInterval: 0.5, target: self,  selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        currentPlaylist?.name = playlistNameTextField.text ?? "New Playlist"
        CoreDataHelper.savePlaylist()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toAddSongsToPlaylist"
        {
            let destinationVC = (segue.destination as? AddSongsToPlaylistViewController)
            destinationVC?.currentPlaylist = self.currentPlaylist
        }
    }
    
    func back(sender: UIBarButtonItem)
    {
        if (currentPlaylist?.playlistSongs?.count)!  <= 0
        {
            CoreDataHelper.deletePlaylist(playlist: currentPlaylist!)
        }
        else
        {
            CoreDataHelper.savePlaylist()
            Answers.logCustomEvent(withName: "Play/Pause Button Tapped", customAttributes: nil)
        }
    }
    
    @IBAction func addMusicButtonTapped(_ sender: UIButton)
    {
        Answers.logCustomEvent(withName: "Add Music To Playlist Button Tapped", customAttributes: nil)
    }
    
    

    
    
   
    
    // MARK: - Play Song Functions
    func prepareForPlaySong(index: Int, songCell: PlaylistSongsTableViewCell)
    {
        // Set the selected song to the row the user tapped
        let selectedSong = currentPlaylist?.playlistSongs?.object(at: index) as? Song
        let downloadProgress = songCell.downloadProgressBar
        let path: String?
        // Present the progress bar and set the progress to 0
        downloadProgress?.alpha = 1.0
        downloadProgress?.progress = 0
        
        if (selectedSong?.id?.hasPrefix("id:"))!
        {
            path = selectedSong?.id
        }
        else
        {
            path = "id:" + (selectedSong?.id)!
        }
        SongPlayerHelper.isSongDownloading = true
        DropboxHelper.downloadFileAsURL(song: selectedSong!, directory: path ?? "", progressBar: (downloadProgress)!, onCompletion: { (downloadedSongURL) in
            SongPlayerHelper.currentSongURL = downloadedSongURL
            
            SongPlayerHelper.isSongDownloading = false
            SongPlayerHelper.currentSongIndexInQueue = (self.selectedRow?.row)!
            SongPlayerHelper.currentSongTitle = selectedSong?.title
            self.playSongAsURL(songURL: SongPlayerHelper.currentSongURL!)
            
        })
        
    }
    
    
    func prepareForPlaySongInitial(songQueue: [Song])
    {
        // Set the selected song to the row the user tapped
        let selectedSong = currentPlaylist?.playlistSongs?.object(at: 0) as? Song
        let songCell = tableView.cellForRow(at: indexPathOfFirstSong!) as? SongsTableViewCell
        let downloadProgress = songCell?.downloadProgressBar
        self.selectedRow = indexPathOfFirstSong
        self.previousRow = indexPathOfFirstSong
        SongPlayerHelper.currentSongTitle = selectedSong?.title
        
        // Present the progress bar and set the progress to 0
        downloadProgress?.alpha = 1.0
        downloadProgress?.progress = 0
        
        let path = "id:" + (selectedSong?.id)!
        SongPlayerHelper.isSongDownloading = true
        DropboxHelper.downloadFileAsURL(song: selectedSong!, directory: path, progressBar: (downloadProgress)!, onCompletion: { (downloadedSongURL) in
            SongPlayerHelper.currentSongURL = downloadedSongURL
            
            SongPlayerHelper.isSongDownloading = false
            SongPlayerHelper.currentSongIndexInQueue = (self.selectedRow?.row)!
            self.playSongAsURL(songURL: SongPlayerHelper.currentSongURL!)
            
        })
        
    }
    
    // Function that handles playing the song with AVAudioPlayer
    func playSongAsURL(songURL: URL)
    {
        
        do {
            // sets the default image to pause since the player presents itself when a song is playing
            SongPlayerHelper.audioPlayer = try AVAudioPlayer(contentsOf: songURL)
            SongPlayerHelper.audioPlayer.delegate = self
            SongPlayerHelper.audioPlayer.prepareToPlay()
            
            
            
            
            // Updates the slider position regularly at the specified interval
            Timer.scheduledTimer(timeInterval: 0.05, target: self,  selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            
            // Play song
            SongPlayerHelper.isSongLoaded = true
            SongPlayerHelper.audioPlayer.play()
            
            Answers.logCustomEvent(withName: "Song Started Playing", customAttributes: nil)
            
            
            // This block of code allows the user to listen to music in the background
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
                //print("AVAudioSession Category Playback OK")
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    //print("AVAudioSession is Active")
                } catch {
                    print(error)
                }
            } catch {
                print(error)
            }
        } catch {
            print("error playing file")
        }
        
    }
    
    // Convert to minutes and seconds
    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    // Utility function for the slider
    @objc func updateTime(_ timer: Timer)
    {
        // Update the time labels
        let (minElapsed, secElapsed) = secondsToMinutesSeconds(seconds: Int(SongPlayerHelper.audioPlayer.currentTime))
        let (minRemaining, secRemaining) = secondsToMinutesSeconds(seconds: (Int(SongPlayerHelper.audioPlayer.duration-SongPlayerHelper.audioPlayer.currentTime)))
        
        
    }
    
    // Cancel the download of the song at the given filepath
    func cancelDownload(forSongAt filePath: String)
    {
        DropboxHelper.cancelDownloadingFile(directory: filePath, onCompletion: { () in
            
        })
    }
    
}

extension PlaylistDetailViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // number of songs in the playlist
        return (currentPlaylist?.playlistSongs?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistSongCell") as! PlaylistSongsTableViewCell
        let text = (currentPlaylist?.playlistSongs?.object(at: indexPath.row) as! Song).title
        let song = (currentPlaylist?.playlistSongs?.object(at: indexPath.row) as! Song)
        cell.songTitleLabel.text = text
        cell.downloadProgressBar.progress = song.downloadPercent
        cell.downloadProgressBar.alpha = 0
        if indexPath.row == 0
        {
            indexPathOfFirstSong = indexPath
            
        }
        
        return cell
    }
    
    // Song selected in the table view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Set the song queue to the displayed songs when a user selects a cell
        SongPlayerHelper.songQueue = (self.currentPlaylist?.playlistSongs?.array as? [Song])!
        
        // Set the selected row to the row the user taps
        self.selectedRow = indexPath
        
        let selectedCell = tableView.cellForRow(at: self.selectedRow!) as? PlaylistSongsTableViewCell
        
        // if the selected row is different than the previous one selected
        if self.previousRow != self.selectedRow
        {
            // if you spam the same row, it cancels downloading and redownloads
            if let previousRow = self.previousRow
            {
                let previousCell = tableView.cellForRow(at: previousRow) as? PlaylistSongsTableViewCell
                
                if SongPlayerHelper.isSongDownloading
                {
                    // cancel download of previous file
                    let songFilePath = (currentPlaylist?.playlistSongs?.object(at: previousRow.row) as? Song)?.filePath
                    cancelDownload(forSongAt: songFilePath!)
                    // Hide and reset the progress bar for the previous cell
                    previousCell?.downloadProgressBar.progress = 0.0
                    previousCell?.downloadProgressBar.alpha = 0.0
                }
                
            }
            
            previousIndexPath = IndexPath(row: indexPath.row - 1 , section: indexPath.section)
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            
            // Play the desired song song
            self.previousRow = indexPath
            prepareForPlaySong(index: indexPath.row, songCell: selectedCell!)
        }
        
    }
    
    // The height of the songs cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55
    }
    
    
    // Deleting songs from playlist
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let mutableItems = currentPlaylist?.playlistSongs?.mutableCopy() as! NSMutableOrderedSet
            mutableItems.removeObject(at: indexPath.row)
            currentPlaylist?.playlistSongs = mutableItems.copy() as? NSOrderedSet
            CoreDataHelper.savePlaylist()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                tableView.reloadData()
            })
        }
    }
}
