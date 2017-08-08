//
//  SongsTableViewCell.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/10/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

class SongsTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var downloadProgressBar: SongDownloadProgressView!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    var correspondingSong: Song!
    
    // MARK: - Table View Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.songTitleLabel.lineBreakMode = .byTruncatingMiddle
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

}
