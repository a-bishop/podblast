/**
DetailsViewController.swift
 - author: Andrew Bishop
 - version: 1.0
 - since: 2019-03-07
 */

import UIKit
import SafariServices

/// This class controls the functionality of the details view, which shows the details for a single podcast
class DetailsViewController: UIViewController {
    
    @IBOutlet weak var podImage: UIImageView!
    @IBOutlet weak var podTitle: UILabel!
    @IBOutlet weak var favouritesLink: UIButton!
    @IBOutlet weak var podDesc: UITextView!
    @IBOutlet weak var linkButton: UIButton!
    
    var podcast : PodcastItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        podTitle.text = podcast?.title ?? "no title available"
        podImage.load(url: URL(string: (podcast?.thumbnail ?? "https://thumbs.dreamstime.com/t/microphone-38421348.jpg"))!)
        podDesc.text = podcast?.desc ?? "no description available"
    }
    
    
    /// This function is called when the link button is pressed. It presents the url in a web view.
    ///
    /// - Parameter sender: (UIButton) the linkButton
    @IBAction func linkButtonPressed(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string: podcast!.url)!)
        present(svc, animated: true, completion: nil)
    }
    
    /// This function is called when the "add to favourites" button is pressed. It appends the podcast data to the current array of podcasts on file, through the NSKeyedArchiver coder.
    ///
    /// - Parameter sender: (UIButton) the favouritesLink
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if var pods = NSKeyedUnarchiver.unarchiveObject(withFile: PodcastItem.archiveURL.path) as? [PodcastItem] {
            
            pods.append(podcast!)
            
            if !NSKeyedArchiver.archiveRootObject(pods, toFile: PodcastItem.archiveURL.path) {
                print("there was a problem saving")
            }
        } else {
            if !NSKeyedArchiver.archiveRootObject([podcast!], toFile: PodcastItem.archiveURL.path) {
                print("there was a problem saving")
            }
        }
        
    }
}
