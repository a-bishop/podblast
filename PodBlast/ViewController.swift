/**
ViewController.swift
 - author: Andrew Bishop
 - version: 1.0
 - since: 2019-03-07
*/

import UIKit


extension UIViewController {
    /// This function is used to hide the keyboard when the user taps out of search or text fields.
    func hideKeyboardWhenTapped() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    /// This is a helper function for "hideKeyboardWhenTapped".
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

/**
This class controls the main view of the application, displaying the search bar, genre picker, and link
to the Favourites view.
*/
class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate {
    

    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var genrePicker: UIPickerView!
    @IBOutlet weak var genreButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// A list of all the valid genres found by querying the "genres" endpoint of the ListenNotes API
    var genreData: [String] = ["VR & AR", "Web Design", "Golf", "English Learning", "Programming", "Personal Finance", "Parenting", "LGBTQ", "SEO", "American History", "Venture Capital", "Movie", "Chinese History", "Locally Focused", "San Francisco Bay Area", "Denver", "Startup", "NFL", "Harry Potter", "Game of Thrones", "Storytelling", "YouTube", "Other Games", "Automotive", "Video Games", "Hobbies", "Aviation", "United States", "China", "Star Wars", "AI & Data Science", "Podcasts", "TV & Film", "Religion & Spirituality", "Spirituality", "Islam", "Buddhism", "Judaism", "Other", "Christianity", "Hinduism", "Sports & Recreation", "Professional", "Outdoor", "College & High School", "Amateur", "Games & Hobbies", "Health", "Fitness & Nutrition", "Self-Help", "Alternative Health", "Sexuality", "Business", "Careers", "Business News", "Shopping", "Management & Marketing", "Investing", "News & Politics", "Arts", "Performing Arts", "Food", "Visual Arts", "Literature", "Design", "Fashion & Beauty", "Science & Medicine", "Social Sciences", "Medicine", "Natural Sciences", "Education", "Educational Technology", "Higher Education", "K-12", "Training", "Language Courses", "Government & Organizations", "Local", "Crypto & Blockchain", "True Crime", "Non-Profit", "Regional", "National", "Society & Culture", "Places & Travel", "Personal Journals", "Philosophy", "Software How-To", "Podcasting", "Gadgets", "Tech News", "Kids & Family", "Comedy", "Music", "New York", "Star Trek", "Apple", "History", "NBA", "Technology", "Audio Drama", "Fiction", "Sales"]
    
    var podcasts = [PodcastItem]()
    var podcast = PodcastItem()
    var listenNotes : ListenNotesClient!
    var urlString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genrePicker.delegate = self
        genrePicker.dataSource = self
        genreButton.sizeToFit()
        searchBar.delegate = self
        searchBar.placeholder = "Enter a podcast name or topic"
        listenNotes = ListenNotesClient()
        hideKeyboardWhenTapped()
    
    }
    
    /**
     This method is called when the view reappears through navigation. It recreates a new instance of the
     ListenNotes client, to prevent data from previous API call being used for new call.
    */
    override func viewDidAppear(_ animated: Bool) {
        listenNotes = ListenNotesClient()
    }
    
    /**
    This method is used to create a valid url string and pass it to the ListenNotes client for fetching
    data from the API.
     - parameters:
        - url: (string) This is the string passed in from the search bar or picker view
    */
    func createQueryThenFetch(url: String) {
        
        /// Trim whitespace and add '+' between words for API call
        let trimmedString = url.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "+")
        
        urlString = "https://listen-api.listennotes.com/api/v2/search?" + "q=" + trimmedString + "&type=podcast&language=English"

        // Collect details in "details" closure after async function returns
        self.listenNotes.fetchPodcasts(urlString: urlString, completion: {(details: [PodcastItem]) -> Void in
            self.podcasts = details
            self.performSegue(withIdentifier: "PodcastTableViewSegue", sender: self)
        })
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        createQueryThenFetch(url: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        /// ensure that the text displays all lowercase
        searchBar.text = searchText.lowercased()
    }
    
    /**
    This method is called when the genre button is pressed. Sends the text to the createQueryThenFetch
    function
     - parameters:
        - sender: (UIButton) the genre button
    */
    @IBAction func genreButtonPressed(_ sender: UIButton) {
        createQueryThenFetch(url: genreButton.titleLabel!.text!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "PodcastTableViewSegue" {
            guard let detailViewController = segue.destination as? PodcastTableViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            // Pass the podcasts array, the API client and the initial url string to TableView
            detailViewController.podcasts = self.podcasts
            detailViewController.listenNotes = self.listenNotes
            detailViewController.urlString = self.urlString
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genreData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        /// set the first value in list for the button, otherwise it defaults to "genre"
        if (row == 0) {
            genreButton.setTitle(genreData[row], for: .normal)
        }
        return genreData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genreButton.setTitle(genreData[row], for: .normal)
    }

}

