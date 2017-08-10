//
//  DropboxHelper.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/7/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import Foundation
import SwiftyDropbox

struct DropboxHelper
{
    static var counter = 0
    
    static var downloadProgress = 0.0
    
    // On completion, returns the entries in the given directory as Entry objects
    static func getItemsAsMetadata(directory directoryPath: String, onCompletion: @escaping ([Entry]?) -> Void) {
        // Verify user is logged into Dropbox
        if let client = DropboxClientsManager.authorizedClient {
            client.files.listFolder(path: directoryPath).response { response, error in
                if let result = response {
                    
                    let entriesInitialized = result.entries.map { Entry(entryMetadata: $0, id: ($0 as? Files.FileMetadata)?.id ?? "", isSelected: false) }
                    onCompletion(entriesInitialized)
                    
                } else {
                    onCompletion(nil)
                }
            }
        }
    }
    
    
    // On completion, returns all items in given directory
    static func getItems(directory directoryPath: String, onCompletion: @escaping ([Item]?) -> Void) {
        var filesInDirectory = [Item]()
        
        // Verify user is logged into Dropbox
        if let client = DropboxClientsManager.authorizedClient {
            
            client.files.listFolder(path: directoryPath).response { response, error in
                if let result = response {
                    for entry in result.entries {
                        let id = (entry as? Files.FileMetadata)?.id.components(separatedBy: ":")[1]
                        let newItem = Item(name: entry.name, rootDirectory: directoryPath, id: id ?? "")
                        
                        
                        filesInDirectory.append(newItem)
                    }
                    onCompletion(filesInDirectory)
                    
                } else {
                    print(error!)
                    onCompletion(nil)
                }
            }
        }
    }
    
    // Checks if item has a subdirectory. Any given file should not have a subdirectory.
    // Parameters
    // - The file path for the file or folder we are checking
    // - The name of said file
    // Returns
    // - True, if given name for folder contains files
    // - False, if given name for file or folder does not contain any files
    
    static func hasSubdirectory(filePath: String, onCompletion: @escaping (Bool?) -> Void)
    {
        // Verify user is logged into Dropbox
        if let client = DropboxClientsManager.authorizedClient
        {
            // Construct string for the full path
            client.files.listFolder(path: filePath).response { response, error in
                if response != nil
                {
                    if response != nil
                    {
                        onCompletion(true)
                    } else
                    {
                        onCompletion(false)
                    }
                    
                }
            }
            
        }
        
    }
    
    
    // Download a file at the given directory
    static func downloadFile(song: Song, directory: String, progressBar: UIProgressView, onCompletion: @escaping (Data?) -> Void)
    {
        if let client = DropboxClientsManager.authorizedClient
        {
            client.files.download(path: directory)
                .response { response, error in
                    if let response = response {
                        let responseMetadata = response.0
                        print(responseMetadata)
                        
                        let fileContents = response.1
                        print(fileContents)
                        onCompletion(fileContents)
                    } else if let error = error {
                        print(error)
                        onCompletion(nil)
                    }
                }
                .progress { progressData in
                    //print(progressData)
                    downloadProgress = progressData.fractionCompleted
                    song.downloadPercent = Float(downloadProgress)
                    progressBar.progress = Float(downloadProgress)
            }
        }
    }
    
    
    // Download a file at the given directory
    static func downloadFileAsURL(song: Song, directory: String, progressBar: UIProgressView, onCompletion: @escaping (URL?) -> Void)
    {
        if let client = DropboxClientsManager.authorizedClient
        {
            let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                let fileManager = FileManager.default
                let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                
                // generate a unique name for this file in case we've seen it before
                let UUID = NSUUID().uuidString
                let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
                
                return directoryURL.appendingPathComponent(pathComponent)
            }
            
            client.files.download(path: directory, destination: destination)
                .response { response, error in
                    if let response = response {
                        let responseMetadata = response.0
                        print(responseMetadata)
                        
                        let fileContents = response.1
                        onCompletion(fileContents)
                    } else if let error = error {
                        print(error)
                        onCompletion(nil)
                    }
                }
                .progress { progressData in
                    //print(progressData)
                    downloadProgress = progressData.fractionCompleted
                    song.downloadPercent = Float(downloadProgress)
                    progressBar.progress = Float(downloadProgress)
            }
        }
    }
    
    
    
    
    // Cancel downloading a file at the given directory
    static func cancelDownloadingFile(directory: String, onCompletion: @escaping (Void) -> Void)
    {
        if let client = DropboxClientsManager.authorizedClient
        {
            client.files.download(path: directory).cancel()
        }
    }
}


