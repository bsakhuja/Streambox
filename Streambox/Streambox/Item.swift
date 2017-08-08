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
    var name: String
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
    init(name: String, rootDirectory: String, id: String)
    {
        
        self.name = name
        self.nameAsNSString = name as NSString
        self.fileNameWithoutExtension = nameAsNSString.deletingPathExtension
        self.fileNameExtension = nameAsNSString.pathExtension
        self.rootDirectory = rootDirectory
        self.filePath = rootDirectory + "/" + name
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
        
        super.init()
        
        self.initializeChildren(directory: filePath, startIndex: self.startIndex, endIndex: self.endIndex)
        
        
    }
    
    
    // need to reload tableview somewhere in here for selectfoldersviewcontroller
    func initializeChildren(directory: String, startIndex: Int, endIndex: Int)
    {
        DropboxHelper.counter += 1
        
        DropboxHelper.getItems(directory: filePath, onCompletion: { (retrievedItems) in
            if let retrievedItems = retrievedItems
            {
                self.children = retrievedItems
                
                for item in self.children!
                {
                    print(item.name)
                    self.startIndex += 1
                    
                    if item.children != nil
                    {
                        self.initializeChildren(directory: item.filePath, startIndex: self.startIndex, endIndex: self.endIndex)
                    } else {
                        // for children assign their own index
                        self.endIndex += 1
                        // recursively define end index to parents
                        
                    }
                }
                
            }
            DropboxHelper.counter -= 1
            if DropboxHelper.counter == 0{
                print("DONE GETTING ALL FILES")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DoneInitializing"), object: nil)
            }
        })
        
        
    }
    
    
    
    
    
}
