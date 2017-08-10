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
    static var currentSong: Data?
    static var currentSongURL: URL?
    static var isSongDownloading = false
    static var isSongLoaded = false
    
    static var currentSongTitle: String?
    static var currentSongTimeElapsed: String?
    static var currentSongTimeRemaining: String?
    
    static var audioPlayer = AVAudioPlayer()
    static let audioInfo = MPNowPlayingInfoCenter()
    static var nowPlayingInfo: [String:AnyObject] = [:]
    
    // TODO: - GET URL
//    static let playerItem = AVPlayerItem(url: )
//    static let metadataList = playerItem.asset.metadata
}
