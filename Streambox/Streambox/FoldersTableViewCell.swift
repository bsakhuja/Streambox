//
//  FoldersTableViewCell.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/7/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

// Protocol for selecting an entry
protocol SelectEntryProtocol: class
{
    func whenEntryIsSelected(cell: FoldersTableViewCell)
}

class FoldersTableViewCell: UITableViewCell
{
    // MARK: - Properties
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet var checkbox: UIButton!

    var entryOfThisCell: Entry?
    var rowOfThisCell = 0
    var isCellSelected = false
    
    weak var delegate: SelectEntryProtocol?
    
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
    
    @IBAction func checkboxTapped(_ sender: UIButton)
    {
        delegate?.whenEntryIsSelected(cell: self)
    }

}




