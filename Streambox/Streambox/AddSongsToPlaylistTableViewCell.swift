//
//  AddSongsToPlaylistTableViewCell.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/10/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

// Protocol for selecting a song
protocol SelectSongDelegate: class
{
    func whenSongIsSelected(cell: AddSongsToPlaylistTableViewCell)
}

class AddSongsToPlaylistTableViewCell: UITableViewCell
{
    
    // MARK: - Properties
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var checkbox: UIButton!
    
    var songOfThisCell: Song?
    
    weak var delegate: SelectSongDelegate?
    
    // MARK: - Table View Cell Lifecycle
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.songTitleLabel.lineBreakMode = .byTruncatingMiddle  // truncate text in the middle
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
    }

    @IBAction func checkboxTapped(_ sender: UIButton)
    {
        delegate?.whenSongIsSelected(cell: self)
    }

}
