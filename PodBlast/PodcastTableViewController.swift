/**
 PodcastTableViewController.swift
 - author: Andrew Bishop
 - version: 1.0
 - since: 2019-03-07
 */

import UIKit

extension UIImageView {
    /// extension to UIImageView which loads images from image URLs
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

/// This class is used to control the behaviour of the table view. It manages multiple API calls as the user scrolls through the table view and reloads the data as needed, using the UITableViewDataSourcePrefetching protocol.
class PodcastTableViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    let cellIdentifier = "PodcastTableViewCell"
    var podcasts : [PodcastItem]?
    var listenNotes : ListenNotesClient?
    var urlString : String?
    var isFetchInProgress = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.prefetchDataSource = self
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listenNotes?.totalPodcasts ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PodcastTableViewCell else {
            fatalError("Selected cell is not of type \(cellIdentifier)")
        }
        var item = PodcastItem()
        // Check to ensure that the index is not greater than the total number of podcasts in the original query
        if (indexPath.row < listenNotes!.currCount) {
            item = self.podcasts![indexPath.row]
        }
        cell.podDesc.text = item.desc
        cell.podTitle.text = item.title
        cell.podImage.load(url: URL(string: item.thumbnail)!)

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "TableToDetailsSegue" {
            guard let detailViewController = segue.destination as? DetailsViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            guard let selectedTableViewCell = sender as? PodcastTableViewCell else {
                fatalError("Unexpected destination \(String(describing:sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedTableViewCell) else {
                fatalError("Unexpected index path for \(selectedTableViewCell)")
            }
            detailViewController.podcast = podcasts?[indexPath.row]
        }
    }
    
    /// This method is called when the fetchPodcasts function is returned.
    ///
    /// - Parameter newIndexPathsToReload: The cells of the table view to reload when a new fetch function is returned
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            tableView.isHidden = false
            tableView.reloadData()
            return
        }
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }


    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // if there are still indexPaths without data...
        if indexPaths.contains(where: isLoadingCell) {
            
            // don't initiate fetch unless current fetch has finished
            guard !self.isFetchInProgress else {
                return
            }
            
            self.isFetchInProgress = true
            
            // the fetch function returns a closure after completing the async task
            listenNotes!.fetchPodcasts(urlString: self.urlString!, completion: {(details: [PodcastItem]) -> Void in
                self.isFetchInProgress = false
                self.podcasts!.append(contentsOf: details)
                let indexPathsToReload = self.calculateIndexPathsToReload(from: details)
                self.onFetchCompleted(with: indexPathsToReload)
            })
        }
    }
    
    
    /// This is a helper function to check if the cell at the indexPath is loading data
    ///
    /// - Parameter indexPath: The indexPath to check
    /// - Returns: boolean
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= listenNotes!.currCount
    }
    
    
    /// This function returns the intersection of the index paths to reload and the view's visible index paths.
    ///
    /// - Parameter indexPaths: An array of IndexPaths
    /// - Returns: The intersection of the index paths and the indexes of the currently visible rows
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    /// This function calculates the cells of the table view to reload when a new fetch function is returned
    ///
    /// - Parameter podcastItems: An array of PodcastItems
    /// - Returns: An array of IndexPaths
    func calculateIndexPathsToReload(from podcastItems: [PodcastItem]) -> [IndexPath]  {
        let startIndex = listenNotes!.totalPodcasts - listenNotes!.nextOffset
        let endIndex = startIndex + listenNotes!.nextOffset
        return (startIndex..<endIndex).map{ IndexPath(row: $0, section: 0)}
    }

}
