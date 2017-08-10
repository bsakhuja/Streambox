//
//  CoreDataHelper.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/27/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataHelper
{
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let persistentContainer = appDelegate.persistentContainer
    static let managedContext = persistentContainer.viewContext
    
    // MARK: - Song static methods
    
    // create a song
    static func newSong() -> Song
    {
        let song = NSEntityDescription.insertNewObject(forEntityName: "Song", into: managedContext) as! Song
        return song
    }
    
    // save a song
    static func saveSong()
    {
        do
        {
            try managedContext.save()
        }
        catch let error as NSError
        {
            print("Could not save song: \(error)")
        }
    }
    
    // delete a song
    static func deleteSong(song: Song)
    {
        managedContext.delete(song)
        saveSong()
    }
    
    // delete all songs
    static func deleteAllSongs()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
        let deleteAllRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do
        {
            try managedContext.execute(deleteAllRequest)
        }
        catch
        {
            print(error)
        }
    }
    
    // retrieve all songs
    static func retrieveSongs() -> [Song]
    {
        let fetchRequest = NSFetchRequest<Song>(entityName: "Song")
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            return results
        } catch let error as NSError
        {
            print("Could not fetch songs: \(error)")
        }
        return []
    }
    
    // MARK: - User static methods
    static func newUser() -> User
    {
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: managedContext) as! User
        return user
    }
    
    static func saveUser()
    {
        do
        {
            try managedContext.save()
        } catch let error as NSError
        {
            print("Could not save user: \(error)")
        }
    }
    
    static func deleteUser(user: User)
    {
        managedContext.delete(user)
        saveUser()
    }
    
    static func retrieveUser() -> [User]
    {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            return results
        } catch let error as NSError
        {
            print("Could not fetch users: \(error)")
        }
        return []
    }
    
    // delete all users
    static func deleteAllUsers()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let deleteAllRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do
        {
            try managedContext.execute(deleteAllRequest)
        }
        catch
        {
            print(error)
        }
    }
    
    
    // MARK: - Playlist Static Functions
    static func newPlaylist() -> Playlist
    {
        let playlist = NSEntityDescription.insertNewObject(forEntityName: "Playlist", into: managedContext) as! Playlist
        return playlist
    }
    
    static func savePlaylist()
    {
        do
        {
            try managedContext.save()
        } catch let error as NSError
        {
            print("Could not save playlist: \(error)")
        }
    }
    
    static func deletePlaylist(playlist: Playlist)
    {
        managedContext.delete(playlist)
        savePlaylist()
    }
    
    // delete all playlists
    static func deleteAllPlaylists()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        let deleteAllRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do
        {
            try managedContext.execute(deleteAllRequest)
        }
        catch
        {
            print(error)
        }
    }
    
    static func retrievePlaylists() -> [Playlist]
    {
        let fetchRequest = NSFetchRequest<Playlist>(entityName: "Playlist")
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            return results
        } catch let error as NSError
        {
            print("Could not fetch playlists: \(error)")
        }
        return []
    }

}
