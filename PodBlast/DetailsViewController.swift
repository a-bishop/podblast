//
//  DetailsViewController.swift
//  PodBlast
//
//  Created by Leah Bernhardt on 2019-03-17.
//  Copyright © 2019 ICS214. All rights reserved.
//

import UIKit
import SafariServices

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
    
    @IBAction func linkButtonPressed(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string: podcast!.url)!)
        present(svc, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if var pods = NSKeyedUnarchiver.unarchiveObject(withFile: PodcastItem.archiveURL.path) as? [PodcastItem] {
            
            pods.append(podcast!)
            
            if !NSKeyedArchiver.archiveRootObject(pods, toFile: PodcastItem.archiveURL.path) {
                debugPrint("there was a problem saving")
            }
        } else {
            if !NSKeyedArchiver.archiveRootObject([podcast!], toFile: PodcastItem.archiveURL.path) {
                debugPrint("there was a problem saving")
            }
        }
        
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
