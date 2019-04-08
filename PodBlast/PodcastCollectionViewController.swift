//
//  PodcastCollectionViewController.swift
//  PodBlast
//
//  Created by Andrew on 2019-03-20.
//  Copyright © 2019 ICS214. All rights reserved.
//

import UIKit
import os

private let reuseIdentifier = "podcastCell"

class PodcastCollectionViewController: UICollectionViewController {
    
    var podcasts : [PodcastItem]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(PodcastCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        podcasts = loadItems()
        // Do any additional setup after loading the view.
    }
    

    // MARK: - Navigation
     
     

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
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

    // MARK: UICollectionViewDataSource
    
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
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }

}
