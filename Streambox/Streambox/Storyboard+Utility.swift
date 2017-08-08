//
//  Storyboard+Utility.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/7/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    enum SBType: String {
        case selectFolders
        case login
        case main
        
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    convenience init(type: SBType, bundle: Bundle? = nil) {
        self.init(name: type.filename, bundle: bundle)
    }
    
    
    static func initialViewController(for type: SBType) -> UIViewController {
        let storyboard = UIStoryboard(type: type)
        guard let initialViewController = storyboard.instantiateInitialViewController() else {
            fatalError("Couldn't instantiate initial view controller for \(type.filename) storyboard.")
        }
        
        return initialViewController
    }
    

}
