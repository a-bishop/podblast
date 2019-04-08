//
//  PodcastTableViewController.swift
//  PodBlast
//
//  Created by Andrew on 2019-03-06.
//  Copyright © 2019 ICS214. All rights reserved.
//

import UIKit

// extension to UIImageView which loads images from image URLs
extension UIImageView {
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

    // MARK: - Table view data source
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
        if (indexPath.row < listenNotes!.currCount) {
            item = self.podcasts![indexPath.row]
        }
        cell.podDesc.text = item.desc
        cell.podTitle.text = item.title
        cell.podImage.load(url: URL(string: item.thumbnail)!)

        return cell
    }
    
    // MARK: - Navigation

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
    
    // MARK: Delegate Methods
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            print("into this block")
            tableView.isHidden = false
            tableView.reloadData()
            return
        }
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }

    
    // MARK: Data Prefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // if there are still indexPaths without data
        if indexPaths.contains(where: isLoadingCell) {
            
            // don't initiate fetch unless current fetch has finished
            guard !self.isFetchInProgress else {
                return
            }
            
            self.isFetchInProgress = true
            
            listenNotes!.fetchPodcasts(urlString: self.urlString!, completion: {(details: [PodcastItem]) -> Void in
                self.isFetchInProgress = false
                self.podcasts!.append(contentsOf: details)
                let indexPathsToReload = self.calculateIndexPathsToReload(from: details)
                self.onFetchCompleted(with: indexPathsToReload)
            })
        }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= listenNotes!.currCount
    }
    
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    // calculates cells of the table view to reload when a new fetch function is returned
    func calculateIndexPathsToReload(from podcastItems: [PodcastItem]) -> [IndexPath]  {
        let startIndex = listenNotes!.totalPodcasts - listenNotes!.nextOffset
        let endIndex = startIndex + listenNotes!.nextOffset
        return (startIndex..<endIndex).map{ IndexPath(row: $0, section: 0)}
    }

}
