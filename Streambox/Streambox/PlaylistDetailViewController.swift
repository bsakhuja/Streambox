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
    
    // MARK: - Toolbar Information
    @IBOutlet weak var toolbar: SongControllerToolbar!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    // MARK: - Current song label
    @IBOutlet weak var currentSongLabel: UILabel!
    
    // MARK: - Song slider
    @IBOutlet weak var songSlider: UISlider!
    
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
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Lato-Light", size: 18)!], for: .normal)
        
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
            // present the song controls
            self.rewindButton.alpha = 1
            self.fastForwardButton.alpha = 1
            self.timeElapsedLabel.alpha = 1.0
            self.timeRemainingLabel.alpha = 1.0
            self.songSlider.alpha = 1.0
            self.currentSongLabel.alpha = 1.0
            // self.currentSongLabel.text = SongPlayerHelper.audioPlayer.
            
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
    
    
    
    @IBAction func unwindToPlaylistsDetailViewController(segue: UIStoryboardSegue)
    {
        
    }
    
    
    // MARK: - Song control functions
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
    
    @IBAction func fastForwardButtonTapped(_ sender: UIButton)
    {
        Answers.logCustomEvent(withName: "Fast Forward Button Tapped", customAttributes: nil)
        
        if let rowOfNextSong = nextIndexPath?.row
        {
            if rowOfNextSong < (currentPlaylist?.playlistSongs?.count)!
            {
                tableView(tableView, didSelectRowAt: nextIndexPath!)
            }
        }
    }
    
    @IBAction func slide(_ sender: UISlider)
    {
        SongPlayerHelper.audioPlayer.currentTime = TimeInterval(songSlider.value)
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
            
            // present the song controls and hide the progress bar
            UIView.animate(withDuration: 0.05) {
                self.rewindButton.alpha = 1
                self.fastForwardButton.alpha = 1
                self.timeElapsedLabel.alpha = 1.0
                self.timeRemainingLabel.alpha = 1.0
                self.songSlider.alpha = 1.0
                self.currentSongLabel.alpha = 1.0
                self.currentSongLabel.text = selectedSong?.title
                downloadProgress?.alpha = 0.0
            }
            
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
            
            // present the song controls and hide the progress bar
            UIView.animate(withDuration: 0.05) {
                self.rewindButton.alpha = 1
                self.fastForwardButton.alpha = 1
                self.timeElapsedLabel.alpha = 1.0
                self.timeRemainingLabel.alpha = 1.0
                self.songSlider.alpha = 1.0
                self.currentSongLabel.alpha = 1.0
                self.currentSongLabel.text = selectedSong?.title
                downloadProgress?.alpha = 0.0
            }
            
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
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            SongPlayerHelper.audioPlayer = try AVAudioPlayer(contentsOf: songURL)
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
    
    // Cancel the download of the song at the given filepath
    func cancelDownload(forSongAt filePath: String)
    {
        DropboxHelper.cancelDownloadingFile(directory: filePath, onCompletion: { (done) in
            
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
