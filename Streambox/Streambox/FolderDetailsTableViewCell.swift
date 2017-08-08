//
//  FolderDetailsTableViewCell.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/12/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

// Protocol for changing the selected boolean array in FolderDetailsViewController
// given row for cell and new boolean
protocol FolderDetailsTableViewCellProtocol: class {
    func updateSelectedArray(for row: Int, to value: Bool)
    
}


class FolderDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var checkbox: UIButton!
    weak var delegate: FolderDetailsTableViewCellProtocol?
    var correspondingItem: Item? // the item that corresponds to the given cell
    var isCheckmarked = true
    var row: Int!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.itemNameLabel.lineBreakMode = .byTruncatingMiddle
    }

    @IBAction func checkboxTapped(_ sender: UIButton) {

        // switch boolean
        isCheckmarked = !isCheckmarked
        
        
        // update the selected array in folder details table view cell using protocol
        delegate?.updateSelectedArray(for: row, to: isCheckmarked)
        print("the button is now \(isCheckmarked)")
        
        // update images based on boolean state of checkbox
        if self.isCheckmarked {
            sender.setImage(#imageLiteral(resourceName: "selected"), for: .normal)
            correspondingItem?.setChildrenToTrue()
        } else {
            sender.setImage(#imageLiteral(resourceName: "unselected"), for: .normal)
            correspondingItem?.setChildrenToFalse()
        }
    }
}
