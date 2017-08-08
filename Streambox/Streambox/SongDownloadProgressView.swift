//
//  SongDownloadProgressView.swift
//  Streambox
//
//  Created by Brian Sakhuja on 7/31/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

class SongDownloadProgressView: UIProgressView {
    
    var height: CGFloat = 1.0
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size:CGSize = CGSize.init(width: self.frame.size.width, height: height)
        
        return size
    }
    
}
