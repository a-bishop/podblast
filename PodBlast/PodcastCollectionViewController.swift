/**
 PodcastCollectionViewController.swift
 - author: Andrew Bishop
 - version: 1.0
 - since: 2019-03-07
 */

import UIKit
import os

private let reuseIdentifier = "podcastCell"

/// This class controls the functionality of the collection view, which displays the user's saved podcasts
class PodcastCollectionViewController: UICollectionViewController {
    
    var podcasts : [PodcastItem]?

    override func viewDidLoad() {
        super.viewDidLoad()
        podcasts = loadItems()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if (segue.identifier == "FavouritesToDetailsSegue") {
            guard let detailViewController = segue.destination as? DetailsViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            guard let selectedCollectionViewCell = sender as? PodcastCollectionViewCell else {
                fatalError("Unexpected destination \(String(describing:sender))")
            }
            guard let indexPath = collectionView.indexPath(for: selectedCollectionViewCell) else {
                fatalError("Unexpected index path for \(selectedCollectionViewCell)")
            }
            detailViewController.podcast = podcasts?[indexPath.row]
        }
    }
    
    /// This function loads the user's saved podcasts from file using NSKeyedUnarchiver
    ///
    /// - Returns: An (optional) array of PodcastItems
    func loadItems() -> [PodcastItem]? {
        if let pods = NSKeyedUnarchiver.unarchiveObject(withFile: PodcastItem.archiveURL.path) as? [PodcastItem] {
            return pods
        } else {
            return nil
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> PodcastCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PodcastCollectionViewCell else {
            fatalError("Selected cell is not of type \(reuseIdentifier)")
        }
        
        let item = self.podcasts?[indexPath.row]
       
        cell.podTitle?.text = item?.title
        cell.podImage?.load(url: URL(string: item?.thumbnail ?? "https://thumbs.dreamstime.com/t/microphone-38421348.jpg")!)
        
        cell.deleteButton?.layer.setValue(indexPath.row, forKey: "index")
        
        return cell
    }

    /// This function is called when the delete button is pressed. It removes the item from file using NSKeyedUnarchiver
    ///
    /// - Parameter sender: (UIButton) the deleteButton
    @IBAction func deletePressed(_ sender: UIButton) {
        let i = (sender.layer.value(forKey: "index")) as! Int
        podcasts?.remove(at: i)
        
        if var pods = NSKeyedUnarchiver.unarchiveObject(withFile: PodcastItem.archiveURL.path) as? [PodcastItem] {
            
            pods.remove(at: i)

            if !NSKeyedArchiver.archiveRootObject(pods, toFile: PodcastItem.archiveURL.path) {
                print("there was a problem saving")
            }
        } else {
            print("could not delete item from archive")
        }
        collectionView.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }

}
