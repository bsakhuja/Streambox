//
//  FoldersTableViewCell.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/7/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

class DropboxTableViewCell: UITableViewCell
{
    // MARK: - Properties
    @IBOutlet weak var itemNameLabel: UILabel!

    var itemOfThisCell: Item?
    var rowOfThisCell = 0
    var isCellSelected = false
    
    // MARK: - Table View Cell Lifecycle
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.itemNameLabel.lineBreakMode = .byTruncatingMiddle  // truncate text in the middle
    }

    override func prepareForReuse()
    {
        super.prepareForReuse()
    }


}




