//
//  PlaylistSongsTableViewCell.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/28/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

class PlaylistSongsTableViewCell: UITableViewCell {

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var downloadProgressBar: SongDownloadProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.songTitleLabel.lineBreakMode = .byTruncatingTail

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
