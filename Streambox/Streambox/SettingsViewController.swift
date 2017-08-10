//
//  AppInfoViewController.swift
//  Streambox
//
//  Created by Brian Sakhuja on 8/7/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit
import Foundation
import Crashlytics

class SettingsViewController: UIViewController
{
    
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Lato-Light", size: 18)!], for: .normal)
        self.navigationItem.title = "Settings"
        
        Answers.logCustomEvent(withName: "Opened Settings", customAttributes: nil)
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIButton)
    {
        // create the alert
        let alert = UIAlertController(title: "Are you sure you want to log out?", message: "You will lose all of your songs and playlists.", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            // delete all songs
            CoreDataHelper.deleteAllSongs()
            
            // delete all playlists
            CoreDataHelper.deleteAllPlaylists()
            
            // delete user
            CoreDataHelper.deleteAllUsers()
            
            // go back to login screen
            self.switchToLogin()
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func switchToLogin() {
        let initialViewController = UIStoryboard.initialViewController(for: .login)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
}
