//
//  SongsViewController.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/7/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

// TODO: - Stop download and resume new song

import UIKit
import Foundation
import AVFoundation
import MediaPlayer
import NVActivityIndicatorView
import Fabric
import Crashlytics

class SongsViewController: UIViewController, NVActivityIndicatorViewable, AVAudioPlayerDelegate, UIToolbarDelegate, UISearchBarDelegate
{
    
    // Items array from the select folders view.  Converted into song objects
    var items = [Item]()
    {
        didSet
        {
            tableView.reloadData()
        }
    }
    
    // Song data types that are displayed in the table view controller
    var filteredSongs = songs
    
    // Utility variables for ensuring that the user can't download a song that they're already playing
    var indexPathOfFirstSong: IndexPath?
    var selectedSongIndexPath: IndexPath?
    var lastSongIndexPath: IndexPath?
    
    // Variables for song controls
    var previousIndexPath: IndexPath?
    var nextIndexPath: IndexPath?
    
    // MARK: - Table View
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Search Bar
    @IBOutlet weak var searchbar: SearchSongsBar!
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Toolbar Information
    @IBOutlet weak var toolbar: SongControllerToolbar!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    // MARK: - Current Song Label
    @IBOutlet weak var currentSongLabel: UILabel!
    
    // MARK: - Song slider
    @IBOutlet weak var songSlider: UISlider!
    
    // MARK: - Download progress view
    
    // MARK: - VC Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        songs = CoreDataHelper.retrieveSongs()
        self.tableView.reloadData()
        
        // Update colors and fonts
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
        
        
        // Used for loading songs in from the add folders view controller
        NotificationCenter.default.addObserver(forName: Notification.Name("DoneInitializing"), object: nil, queue: nil) { (notification) in
            print("notification is \(notification)")
            
            self.reloadSongs()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                // hide activity indicator
                self.stopAnimating()
            }
        }
        
        // Get rid of extra separators by adding a view below
        self.tableView.tableFooterView = UIView()
        
        tableView.dataSource = self
        searchbar.delegate = self
        
        // Set up toolbar
        // TODO: - move bar off screen then move back on when playing
        self.currentSongLabel.alpha = 0
        self.timeRemainingLabel.alpha = 0
        self.rewindButton.alpha = 0
        self.fastForwardButton.alpha = 0
        self.timeElapsedLabel.alpha = 0
        
        // Set up song slider
        let knobSlider = UIImage(named: "needle")
        self.songSlider.alpha = 0
        self.songSlider.value = 0.0
        self.songSlider.setThumbImage(knobSlider, for: .normal)
        
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if SongPlayerHelper.isSongLoaded
        {
            // Updates the slider position regularly at the specified interval
            Timer.scheduledTimer(timeInterval: 0.5, target: self,  selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            // present the song controls
            self.rewindButton.alpha = 1
            self.fastForwardButton.alpha = 1
            self.timeElapsedLabel.alpha = 1.0
            self.timeRemainingLabel.alpha = 1.0
            self.songSlider.alpha = 1.0
            self.currentSongLabel.alpha = 1.0
            // self.currentSongLabel.text = SongPlayerHelper.audioPlayer.
            
        }
    }
    
    func reloadSongs()
    {
        SongPlayerHelper.songQueue.append(contentsOf: songs)
        
        Song.initializeSongs(from: items)
        songs = CoreDataHelper.retrieveSongs()
        filteredSongs = songs
    }
    
    // Called when 'Done' tapped in SelectFoldersViewController
    @IBAction func unwindToSongsViewController(_ segue: UIStoryboardSegue)
    {
        if items.count != 0
        {
            // show activity indicator
            startAnimating(CGSize(width: 50, height: 50), type: .ballClipRotate)
        }
        // make songs
        self.reloadSongs()
        tableView.reloadData()
    }
    
    
    // MARK: - Music Controller Toolbar Actions
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton)
    {
        Answers.logCustomEvent(withName: "Play/Pause Button Tapped", customAttributes: nil)
        if SongPlayerHelper.currentSong == nil
        {
            if !SongPlayerHelper.isSongDownloading && songs.count > 0
            {
                prepareForPlaySongInitial(songQueue: SongPlayerHelper.songQueue)
            }
        }
        else if SongPlayerHelper.audioPlayer.isPlaying
        {
            let playButton = UIImage(named: "play")
            self.playPauseButton.setImage(playButton, for: .normal)
            SongPlayerHelper.audioPlayer.pause()
        }
        else
        {
            let pauseButton = UIImage(named: "pause")
            self.playPauseButton.setImage(pauseButton, for: .normal)
            SongPlayerHelper.audioPlayer.prepareToPlay()
            SongPlayerHelper.audioPlayer.play()
        }
    }
    
    
    
    @IBAction func slide(_ sender: UISlider)
    {
        SongPlayerHelper.audioPlayer.currentTime = TimeInterval(songSlider.value)
    }
    
    @IBAction func rewindButtonTapped(_ sender: UIButton)
    {
        Answers.logCustomEvent(withName: "Rewind Button Tapped", customAttributes: nil)
        if SongPlayerHelper.audioPlayer.currentTime > 5
        {
            SongPlayerHelper.audioPlayer.currentTime = 0
        }
        else
        {
            if let rowOfPreviousSong = previousIndexPath?.row
            {
                if rowOfPreviousSong > 0
                {
                    tableView(tableView, didSelectRowAt: previousIndexPath!)
                }
            }
        }
    }
    
    @IBAction func fastForwardButtonTapped(_ sender: UIButton)
    {
        Answers.logCustomEvent(withName: "Fast Forward Button Tapped", customAttributes: nil)
        if let rowOfNextSong = nextIndexPath?.row
        {
            if rowOfNextSong < filteredSongs.count
            {
                tableView(tableView, didSelectRowAt: nextIndexPath!)
            }
        }
    }
}



extension SongsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // If there are no songs, the default message is shown
        if songs.count == 0
        {
            return 1
        }
        else
        {
            return filteredSongs.count
        }
    }
    
    // The height of the songs cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if songs.count == 0
        {
            return 65
        }
        else
        {
            return 55
        }
        
    }
    
    // Populate tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        // If there are no songs, the default message is shown
        if songs.count == 0
        {
            // Disable search for default message
            searchbar.isUserInteractionEnabled = false
            
            // Initial cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "songSongCell") as! SongsTableViewCell
            let text = "Add songs from your Dropbox by tapping the + icon"
            cell.songArtistLabel.alpha = 0
            cell.isUserInteractionEnabled = false
            cell.downloadProgressBar.alpha = 0
            cell.songTitleLabel.text = text
            cell.songTitleLabel.numberOfLines = 2
            return cell
        }
        else
        {
            // Reenable search interaction
            searchbar.isUserInteractionEnabled = true
            
            // Populate table view with the songs
            let cell = tableView.dequeueReusableCell(withIdentifier: "songSongCell") as! SongsTableViewCell
            let text = filteredSongs[indexPath.row].title
            let song = filteredSongs[indexPath.row]
            cell.correspondingSong = filteredSongs[indexPath.row]
            cell.downloadProgressBar.alpha = 1
            cell.isUserInteractionEnabled = true
            cell.downloadProgressBar.height = 50.0
            cell.downloadProgressBar.progress = 0
            cell.songArtistLabel.alpha = 1
            cell.songTitleLabel.text = text
            cell.songTitleLabel.numberOfLines = 1
            
            if song.isDownloading
            {
                cell.downloadProgressBar.progress = song.downloadPercent
            } else
            {
                cell.downloadProgressBar.alpha = 0
            }
            
            if indexPath.row == 0
            {
                indexPathOfFirstSong = indexPath
            }
            
            return cell
        }
    }
    
    // Song selected in the songs table view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Set the song queue to the displayed songs when a user selects a cell
        SongPlayerHelper.songQueue = self.filteredSongs
        
        
        // Set the selected row to the row the user taps
        self.selectedSongIndexPath = indexPath
        
        let selectedCell = tableView.cellForRow(at: self.selectedSongIndexPath!) as? SongsTableViewCell
        
        if self.lastSongIndexPath != self.selectedSongIndexPath
        {
            if let previousRow = self.lastSongIndexPath
            {
                let previousCell = tableView.cellForRow(at: previousRow) as? SongsTableViewCell
                
                if SongPlayerHelper.isSongDownloading
                {
                    // cancel download of previous file
                    cancelDownload(forSongAt: filteredSongs[previousRow.row].filePath!)
                    
                    // Hide and reset the progress bar for the previous cell
                    previousCell?.downloadProgressBar.progress = 0.0
                    previousCell?.downloadProgressBar.alpha = 0.0
                }
                
            }
            
            previousIndexPath = IndexPath(row: indexPath.row - 1 , section: indexPath.section)
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            
            // Play the desired song song
            self.lastSongIndexPath = indexPath
            prepareForPlaySong(index: indexPath.row, songCell: selectedCell!)
        }
        
    }
    
    
    // Deleting songs
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if filteredSongs.count > 0
        {
            if editingStyle == .delete
            {
                CoreDataHelper.deleteSong(song: filteredSongs[indexPath.row])
                songs = CoreDataHelper.retrieveSongs()
                filteredSongs = songs
                tableView.deleteRows(at: [indexPath], with: .middle)
                Answers.logCustomEvent(withName: "Song Deleted From Library", customAttributes: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    tableView.reloadData()
                })
                
            }
        }
    }
    
    // Cancel the download of the song at the given filepath
    func cancelDownload(forSongAt filePath: String)
    {
        DropboxHelper.cancelDownloadingFile(directory: filePath, onCompletion: { (done) in
            
        })
    }
    
    func prepareForPlaySong(index: Int, songCell: SongsTableViewCell)
    {
        // Set the selected song to the row the user tapped
        let selectedSong = filteredSongs[index]
        let downloadProgress = songCell.downloadProgressBar
        let path: String?
        // Present the progress bar and set the progress to 0
        downloadProgress?.alpha = 1.0
        downloadProgress?.progress = 0
        
        if (selectedSong.id?.hasPrefix("id:"))!
        {
            path = selectedSong.id
        }
        else
        {
            path = "id:" + (selectedSong.id)!
        }
        
        // Set the is downloading states to true
        SongPlayerHelper.isSongDownloading = true
        selectedSong.isDownloading = true
        
        DropboxHelper.downloadFile(song: selectedSong, directory: path ?? "", progressBar: (downloadProgress)!, onCompletion: { (downloadedSong) in
            SongPlayerHelper.currentSong = downloadedSong
            
            // present the song controls and hide the progress bar
            UIView.animate(withDuration: 0.05) {
                self.rewindButton.alpha = 1
                self.fastForwardButton.alpha = 1
                self.timeElapsedLabel.alpha = 1.0
                self.timeRemainingLabel.alpha = 1.0
                self.songSlider.alpha = 1.0
                self.currentSongLabel.alpha = 1.0
                self.currentSongLabel.text = selectedSong.title
                downloadProgress?.alpha = 0.0
            }
            
            // Set the is downloading states to false
            SongPlayerHelper.isSongDownloading = false
            selectedSong.isDownloading = false
            
            SongPlayerHelper.currentSongIndexInQueue = (self.selectedSongIndexPath?.row)!
            SongPlayerHelper.currentSongTitle = selectedSong.title
            self.playSong(song: SongPlayerHelper.currentSong!)
            
        })
        
    }
    
    
    func prepareForPlaySongInitial(songQueue: [Song])
    {
        // Set the selected song to the row the user tapped
        let selectedSong = filteredSongs[0]
        let songCell = tableView.cellForRow(at: indexPathOfFirstSong!) as? SongsTableViewCell
        let downloadProgress = songCell?.downloadProgressBar
        self.selectedSongIndexPath = indexPathOfFirstSong
        self.lastSongIndexPath = indexPathOfFirstSong
        SongPlayerHelper.currentSongTitle = selectedSong.title
        
        // Present the progress bar and set the progress to 0
        downloadProgress?.alpha = 1.0
        downloadProgress?.progress = 0
        
        
        
        let path = "id:" + selectedSong.id!
        
        // Set the is downloading states to true
        SongPlayerHelper.isSongDownloading = true
        selectedSong.isDownloading = true
        
        DropboxHelper.downloadFile(song: selectedSong, directory: path, progressBar: (downloadProgress)!, onCompletion: { (downloadedSong) in
            SongPlayerHelper.currentSong = downloadedSong
            
            // present the song controls and hide the progress bar
            UIView.animate(withDuration: 0.05) {
                self.rewindButton.alpha = 1
                self.fastForwardButton.alpha = 1
                self.timeElapsedLabel.alpha = 1.0
                self.timeRemainingLabel.alpha = 1.0
                self.songSlider.alpha = 1.0
                self.currentSongLabel.alpha = 1.0
                self.currentSongLabel.text = selectedSong.title
                downloadProgress?.alpha = 0.0
            }
            
            // Set the is downloading states to false
            SongPlayerHelper.isSongDownloading = false
            selectedSong.isDownloading = false
            
            SongPlayerHelper.currentSongIndexInQueue = (self.selectedSongIndexPath?.row)!
            self.playSong(song: SongPlayerHelper.currentSong!)
            
        })
        
    }
    
    // Function that handles playing the song with AVAudioPlayer
    func playSong(song: Data)
    {
        
        do {
            // sets the default image to pause since the player presents itself when a song is playing
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            SongPlayerHelper.audioPlayer = try AVAudioPlayer(data: SongPlayerHelper.currentSong!)
            SongPlayerHelper.audioPlayer.delegate = self
            SongPlayerHelper.audioPlayer.prepareToPlay()
            
            // initialize slider for song
            self.songSlider.value = 0.0
            self.songSlider.maximumValue = Float(SongPlayerHelper.audioPlayer.duration)
            //            self.timeRemainingLabel.text = String(self.audioPlayer.duration)
            
            
            
            // Updates the slider position regularly at the specified interval
            Timer.scheduledTimer(timeInterval: 0.05, target: self,  selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            
            // Play song
            SongPlayerHelper.isSongLoaded = true
            SongPlayerHelper.audioPlayer.play()
            Answers.logCustomEvent(withName: "Song Played", customAttributes: nil)
            
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
    func updateTime(_ timer: Timer)
    {
        // Update the time labels
        let (minElapsed, secElapsed) = secondsToMinutesSeconds(seconds: Int(SongPlayerHelper.audioPlayer.currentTime))
        let (minRemaining, secRemaining) = secondsToMinutesSeconds(seconds: (Int(SongPlayerHelper.audioPlayer.duration-SongPlayerHelper.audioPlayer.currentTime)))
        
        if secElapsed < 10
        {
            SongPlayerHelper.currentSongTimeElapsed = "\(minElapsed):0\(secElapsed)"
            self.timeElapsedLabel.text = SongPlayerHelper.currentSongTimeElapsed
        }
        else
        {
            SongPlayerHelper.currentSongTimeElapsed = "\(minElapsed):\(secElapsed)"
            self.timeElapsedLabel.text = SongPlayerHelper.currentSongTimeElapsed
            
        }
        
        if secRemaining < 10
        {
            SongPlayerHelper.currentSongTimeRemaining = "-\(minRemaining):0\(secRemaining)"
            self.timeRemainingLabel.text = SongPlayerHelper.currentSongTimeRemaining
        }
        else
        {
            SongPlayerHelper.currentSongTimeRemaining = "-\(minRemaining):\(secRemaining)"
            self.timeRemainingLabel.text = SongPlayerHelper.currentSongTimeRemaining
        }
        
        // update the slider
        songSlider.maximumValue = Float(SongPlayerHelper.audioPlayer.duration)
        songSlider.value = Float(SongPlayerHelper.audioPlayer.currentTime)
        currentSongLabel.text = SongPlayerHelper.currentSongTitle
        
        
        // If a song is not playing, show the play button
        if !SongPlayerHelper.audioPlayer.isPlaying
        {
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
        else
        {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
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
    
    // Set up the info center
    //    private func setupNowPlayingInfoCenter() {
    //        UIApplication.shared.beginReceivingRemoteControlEvents();
    //        MPRemoteCommandCenter.shared().playCommand.addTarget {event in
    //            self.audioPlayer.play()
    //            self.setupNowPlayingInfoCenter()
    //            return .success
    //        }
    //        MPRemoteCommandCenter.shared().pauseCommand.addTarget {event in
    //            self.audioPlayer.pause()
    //            return .success
    //        }
    //        MPRemoteCommandCenter.shared.nextTrackCommand.addTarget {event in
    //            self.next()
    //            return .Success
    //        }
    //        MPRemoteCommandCenter.shared.previousTrackCommand.addTarget {event in
    //            self.prev()
    //            return .Success
    //        }
    //    }
}
