//
//  Folder.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/10/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit
import SwiftyDropbox

class Item: NSObject {
    let itemMetadata: Files.Metadata
    var name: String?
    var nameAsNSString: NSString
    var fileNameWithoutExtension: String
    var fileNameExtension: String
    var isFolder = false
    var parent: Item?
    var children: [Item]?
    var isMusicFile = false
    var startIndex = 0
    var endIndex = 0
    let id: String = ""
    
    
    // initializer
    init(itemMetadata: Files.Metadata)
    {
        self.itemMetadata = itemMetadata
        self.name = itemMetadata.name
        self.nameAsNSString = name! as NSString
        self.fileNameWithoutExtension = nameAsNSString.deletingPathExtension
        self.fileNameExtension = nameAsNSString.pathExtension
        
        
        if fileNameExtension == "mp3"
        {
            isMusicFile = true
        } else if fileNameExtension == "m4a"
        {
            isMusicFile = true
        } else if fileNameExtension == "wav"
        {
            isMusicFile = true
        } else if fileNameExtension == "aiff"
        {
            isMusicFile = true
        }
    }
}
