//
//  MusicTableViewCell.swift
//  SampleMusicPlayer01
//
//  Created by cao on 2018/05/13.
//  Copyright © 2018年 com.soui. All rights reserved.
//

import UIKit
import Foundation

class MusicTableViewCell: UITableViewCell {

@IBOutlet weak var musicName: UILabel!

@IBOutlet weak var musicIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        musicName.numberOfLines = 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCell(music : ModelMusic) {
        self.musicName.text = music.musicName
        // TODO

    }
}
