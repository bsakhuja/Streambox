//
//  Entry.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/21/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit
import SwiftyDropbox

class Entry: NSObject {
    
    let entryMetadata: Files.Metadata
    var isSelected = false
    let name: String
    let id: String
    
    init(entryMetadata: Files.Metadata, id: String, isSelected: Bool)
    {
        self.entryMetadata = entryMetadata
        self.isSelected = isSelected
        self.name = entryMetadata.name
        self.id = id
    }
}
