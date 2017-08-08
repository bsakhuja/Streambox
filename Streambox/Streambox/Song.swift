//
//  Song.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/6/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import Foundation
import UIKit
import SwiftyDropbox



extension Song {
    
    // Create song objects from items (from SelectFoldersViewController)
    static func initializeSongs(from items: [Item])
    {
        // iterate through all items in the items array
        for item in items
        {
            // if the item has children, call the function again for the children
            if item.children != nil
            {
                initializeSongs(from: item.children!)
            }
            
            // Base case
            if item.isMusicFile
            {
                let newSongTitle = item.fileNameWithoutExtension
                let allSongs = CoreDataHelper.retrieveSongs()

                // only add a song if it doesn't exist already
                if  allSongs.count > 0 {
                    for song in allSongs {
                        if (song.title?.contains(newSongTitle))! {
                            return
                        }
                    }
                }
                
                // create new song
                let newSong = CoreDataHelper.newSong()
                newSong.filePath = item.filePath
                newSong.id = item.id
                print(item.id)
                newSong.title = item.name
                
                CoreDataHelper.saveSong()
            }
        }
    }
}
