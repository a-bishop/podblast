/**
 PodcastTableViewCell.swift
 - author: Andrew Bishop
 - version: 1.0
 - since: 2019-03-07
 */

import UIKit

/// This class describes the data for each cell in the PodcastTableView
class PodcastTableViewCell: UITableViewCell {

    @IBOutlet weak var podTitle: UILabel!
    @IBOutlet weak var podImage: UIImageView!
    @IBOutlet weak var podDesc: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
