//
//  PodcastTableViewCell.swift
//  PodBlast
//
//  Created by Andrew on 2019-03-03.
//  Copyright © 2019 ICS214. All rights reserved.
//

import UIKit

class PodcastTableViewCell: UITableViewCell {

    @IBOutlet weak var podTitle: UILabel!
    @IBOutlet weak var podImage: UIImageView!
    @IBOutlet weak var podDesc: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
