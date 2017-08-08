//
//  AppInfoViewController.swift
//  Streambox
//
//  Created by Brian Sakhuja on 8/7/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit
import Crashlytics

class AppInfoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Lato-Light", size: 18)!], for: .normal)
        
        Answers.logCustomEvent(withName: "Opened Application Information", customAttributes: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
