//
//  SongPlayerHelper.swift
//  Streambox
//
//  Created by Brian Sakhuja on 8/1/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import MediaPlayer

class SongPlayerHelper: NSObject, AVAudioPlayerDelegate
{
    static var songQueue = [Song]()
    static var currentSongIndexInQueue: Int = 0
    static var currentSong: Song?
    static var currentSongURL: URL?
    static var isSongDownloading = false
    static var isSongLoaded = false
    
    static var currentSongTitle: String?
    static var currentSongArtist: String?
    static var currentSongArtwork: UIImage?
    static var currentSongTimeElapsed: String?
    static var currentSongTimeRemaining: String?
    
    static var audioPlayer = AVAudioPlayer()
        
    
    
    // Derived from https://stackoverflow.com/questions/30243658/displaying-artwork-for-mp3-file
    static func getID3Tags()
    {
        // For retrieving song information
        let playerItem = AVPlayerItem(url: SongPlayerHelper.currentSongURL!)
        let metadataList = playerItem.asset.metadata
        
        currentSongTitle = currentSong?.title
        currentSongArtist = "unknown artist"
        currentSongArtwork = #imageLiteral(resourceName: "white")
        
        for item in metadataList
        {
            guard let key = item.commonKey, let value = item.value else
            {
                continue
            }
            
            switch key
            {
            case "title" :
                if (value as? String) != "" && (value as? String) != nil
                {
                    currentSongTitle = (value as? String)
                }
            case "artist" :
                if value as? String != "" && value as? String != nil
                {
                    currentSongArtist = value as? String
                }
            case "artwork" where value is NSData :
                if let img = UIImage(data: value as! Data)
                {
                    currentSongArtwork = img
                }
            // case type (for genre)
            default:
                continue
            }
            
            // Handle empty song titles, artists, etc.
            
        }
    }
    
    static func updateNowPlayingInfoCenter()
    {
//        let audioInfo = MPNowPlayingInfoCenter
//        let nowPlayingInfo: [String : Any] =  [
//            MPMediaItemPropertyTitle: SongPlayerHelper.currentSongTitle ?? "unknown title",
//            MPMediaItemPropertyArtist: SongPlayerHelper.currentSongArtist ?? "unknown artist",
//            MPNowPlayingInfoPropertyElapsedPlaybackTime: SongPlayerHelper.audioPlayer.currentTime,
//            MPMediaItemPropertyPlaybackDuration: SongPlayerHelper.audioPlayer.duration,
//            MPNowPlayingInfoPropertyPlaybackRate: 1.0]
//        audioInfo.nowPlayingInfo = nowPlayingInfo
    }
    
}
