//
//  PlaylistsTableViewCell.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/10/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

class PlaylistsTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var playlistName: String?
    var correspondingPlaylist: Playlist?
    
    @IBOutlet weak var playlistNameLabel: UILabel!
    
    // MARK: - Table View Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.playlistNameLabel.lineBreakMode = .byTruncatingTail

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
