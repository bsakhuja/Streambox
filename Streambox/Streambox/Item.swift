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
    var rootDirectory: String
    var filePath: String
    var isSelected = false
    var parent: Item?
    var children: [Item]?
    var isMusicFile = false
    var startIndex = 0
    var endIndex = 0
    let id: String
    
    
    // initializer
    init(itemMetadata: Files.Metadata, rootDirectory: String, id: String)
    {
        self.itemMetadata = itemMetadata
        self.name = itemMetadata.name
        self.nameAsNSString = name! as NSString
        self.fileNameWithoutExtension = nameAsNSString.deletingPathExtension
        self.fileNameExtension = nameAsNSString.pathExtension
        self.rootDirectory = rootDirectory
        self.filePath = rootDirectory + "/" + name!
        self.id = id
        
        
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
