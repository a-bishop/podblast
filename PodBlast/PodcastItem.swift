/**
 PodcastItem.swift
 - author: Andrew Bishop
 - version: 1.0
 - since: 2019-03-07
 */

import Foundation
import UIKit
import os

/// This class describes the data in a Podcast Item. It also handles the decoding and encoding of the object for saving to, and deleting from, file
class PodcastItem: NSObject, NSCoding {
    var thumbnail: String
    var title: String
    var desc: String
    var url: String
    
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    static let archiveURL = documentsDirectory.appendingPathComponent("podcastItems")
    
    /// These are the default values for initialization in case any podcast objects are missing parameters
    override convenience init() {
        self.init(thumbnail: "https://thumbs.dreamstime.com/t/microphone-38421348.jpg", title: "default title", desc: "default description", url: "default url")
    }
    
    init(thumbnail: String, title: String, desc: String, url: String) {
        self.thumbnail = thumbnail
        self.title = title
        self.desc = desc
        self.url = url
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let thumbnail = aDecoder.decodeObject(forKey: "thumbnail") as? String else {
            debugPrint("Unable to decode the thumbnail for Podcast object")
            return nil
        }
        guard let title = aDecoder.decodeObject(forKey: "title") as? String else {
            debugPrint("Unable to decode the title for Podcast object")
            return nil
        }
        guard let desc = aDecoder.decodeObject(forKey: "desc") as? String else {
            debugPrint("Unable to decode the description for Podcast object")
            return nil
        }
        guard let url = aDecoder.decodeObject(forKey: "url") as? String else {
            debugPrint("Unable to decode the url for Podcast object")
            return nil
        }
        self.init(thumbnail: thumbnail, title: title, desc: desc, url: url)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(thumbnail, forKey: "thumbnail")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(desc, forKey: "desc")
        aCoder.encode(url, forKey: "url")
    }
   
}
