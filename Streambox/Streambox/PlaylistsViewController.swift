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
        
        
        // Set up toolbar
        // TODO: - move bar off screen then move back on when playing
        self.currentSongLabel.alpha = 0
        self.rewindButton.alpha = 0
        self.fastForwardButton.alpha = 0
        self.timeRemainingLabel.alpha = 0
        self.timeElapsedLabel.alpha = 0
        
        // Set up song slider
        let knobSlider = UIImage(named: "needle")
        self.songSlider.alpha = 0
        self.songSlider.value = 0.0
        self.songSlider.setThumbImage(knobSlider, for: .normal)
        
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
            // Updates the slider position regularly at the specified interval
            Timer.scheduledTimer(timeInterval: 0.05, target: self,  selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            // present the song controls
            self.rewindButton.alpha = 1
            self.fastForwardButton.alpha = 1
            self.timeElapsedLabel.alpha = 1.0
            self.timeRemainingLabel.alpha = 1.0
            self.songSlider.alpha = 1.0
            self.currentSongLabel.alpha = 1.0
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
    
    func showToolbar()
    {
        // Set up toolbar
        self.rewindButton.alpha = 1
        self.fastForwardButton.alpha = 1
        self.currentSongLabel.alpha = 1
        self.currentSongLabel.text = SongPlayerHelper.songQueue[SongPlayerHelper.currentSongIndexInQueue].title
        self.timeRemainingLabel.alpha = 1
        self.timeElapsedLabel.alpha = 1
        
        
        // Set up song slider
        let knobSlider = UIImage(named: "needle")
        self.songSlider.alpha = 1
        self.songSlider.value = 0
        self.songSlider.setThumbImage(knobSlider, for: .normal)
    }
    
    
    // MARK: - Song Control Functions
    @IBAction func rewindButtonTapped(_ sender: UIButton)
    {
        Answers.logCustomEvent(withName: "Rewind Button Tapped", customAttributes: nil)
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton)
    {
        Answers.logCustomEvent(withName: "Play/Pause Button Tapped", customAttributes: nil)
        
        if SongPlayerHelper.currentSong == nil
        {
            // TODO: - Play queue
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
    }
    
    @IBAction func slide(_ sender: UISlider)
    {
        SongPlayerHelper.audioPlayer.currentTime = TimeInterval(songSlider.value)
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
