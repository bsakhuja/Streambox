//
//  ViewController.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/6/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit
import SwiftyDropbox
import Crashlytics

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !users.isEmpty
        {
            switchToMainViewController()
        }
        
        loginButton.layer.cornerRadius = 9
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    // MARK: - IBAction
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Begin the authorization flow
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        if #available(iOS 10.0, *) {
                                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                        } else {
                                                            UIApplication.shared.openURL(url)
                                                        }
                                                        // Verify user is logged into Dropbox
                                                        if let client = DropboxClientsManager.authorizedClient
                                                        {
                                                            
                                                            // Get the current user's account info
                                                            client.users.getCurrentAccount().response { response, error in
                                                                if let account = response
                                                                {
                                                                    let user = CoreDataHelper.newUser()
                                                                    user.id = account.accountId
                                                                    user.email = account.email
                                                                    
                                                                    
                                                                    Answers.logSignUp(withMethod: "Using Dropbox API", success: 1, customAttributes: [user.email!: user])
                                                                    // switch to main view controller
                                                                    self.switchToMainViewController()
                                                                    
                                                                    
                                                                }
                                                                else
                                                                {
                                                                    print(error!)
                                                                }
                                                            }
                                                        }
        })
        
        
        
        
    }
    
    
    func switchToMainViewController() {
        let initialViewController = UIStoryboard.initialViewController(for: .main)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    
}
