/**
 PodcastCollectionViewCell.swift
 - author: Andrew Bishop
 - version: 1.0
 - since: 2019-03-07
 */

import UIKit

/// This class describes the data for each cell in the PodcastCollectionView
class PodcastCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var podTitle: UILabel!
    @IBOutlet weak var podImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
}
