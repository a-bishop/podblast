/**
 ListenNotesClient.swift
 - author: Andrew Bishop
 - version: 1.0
 - since: 2019-03-07
 */

import Foundation

/// This class is used to handle calls to the ListenNotes API, and to maintain the offset variable and total number of results when making multiple calls with same query but different offsets
final class ListenNotesClient {
    
    let session: URLSession
    var totalPodcasts: Int
    var currCount: Int
    var nextOffset: Int
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
        self.totalPodcasts = 0
        self.currCount = 0
        self.nextOffset = 0
    }
    
    func fetchPodcasts(urlString: String, completion: @escaping (_ details: [PodcastItem]) -> ()) {
        
        /// Add offsets for fetch based on which page of the query we're at.
        var urlStringCopy = urlString
        urlStringCopy += "&offset=\(self.nextOffset)"
        
        let url = URL(string: urlStringCopy)
        
        /// Convert to URL request and set header for application key
        var urlRequest = URLRequest(url: url!)
        let apiKey = getAPIKey();
        urlRequest.setValue(apiKey, forHTTPHeaderField: "X-ListenAPI-Key")

        /// This variable holds an async dataTask function with a completionHandler closure
        let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
    
            guard error == nil else {
                print("error getting podcasts: \(String(describing: error))!")
                return
            }
        
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return
            }
        
            // make sure we have data
            guard let responseData = data else {
                print("error: did not receive any data")
                return
            }
        
            // parse the result as JSON
            do {
        
                // now we have the podcastData, initialize array of podcast items
                var podcastDetails = [PodcastItem]()
            
                guard let podcastData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("query error trying to convert data to JSON")
                    return
                }
            
                let totalResults = podcastData["total"] as! Int
                let nextOffset = podcastData["next_offset"] as! Int
                let count = podcastData["count"] as! Int
            
                guard let details = podcastData["results"] as? NSArray else {
                    print("query error trying to convert dictionary to array")
                    return
                }
            
                for item in details {
                    if let podDict = item as? NSDictionary {
                
                        let thumbnail = podDict["thumbnail"] as? String ?? "thumbnail not available"
                        let title = podDict["title_original"] as? String ?? "title not available"
                        let description = podDict["description_original"] as? String ?? "description not available"
                        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
                        let url = podDict["listennotes_url"] as? String ?? "url not available"
                        
                        podcastDetails.append(PodcastItem(thumbnail: thumbnail , title: title , desc: trimmedDescription , url:url ))
                    
                    } else {
                        print("data not of correct type")
                        return
                    }
                }
            
                DispatchQueue.main.async {
                    completion(podcastDetails)
                    if (self.totalPodcasts == 0) {
                        // constrain to 100 results if results more than 100
                        self.totalPodcasts = totalResults < 100 ? totalResults : 100
                    }
                    self.currCount += count
                    self.nextOffset = nextOffset
                }
            } catch  {
                print("Something went wrong")
                return
            }
    })
    task.resume()
    }
    
    
    /// Thie function retrieves the ListenNotes API key from the plist file
    ///
    /// - Returns: (string) the ListenNotes API Key
    func getAPIKey () -> String {
        let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let value = plist?.object(forKey: "LISTENNOTES_API_KEY") as! String
        return value
    }
}
