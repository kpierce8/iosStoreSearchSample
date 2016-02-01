//
//  ViewController.swift
//  StoreSearch
//
//  Created by UberDominator on 1/31/16.
//  Copyright © 2016 Frantic Goose Applications. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

        var searchResults = [SearchResult]()
        var hasSearched = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


} // End class

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hasSearched = true
        searchBar.resignFirstResponder()
        searchResults = [SearchResult]()
        
        if searchBar.text != "justin bieber" {
        for i in 0...2 {
            let searchResult = SearchResult()
            searchResult.name = String(format: "Fake result %d for ", i)
            searchResult.artistName = String(format: " '%@'", searchBar.text!)
            searchResults.append(searchResult)
         }
        }
        tableView.reloadData()
    }
    
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if searchResults.count == 0 {
            return 1
        } else {
        return searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResult"
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        if searchResults.count == 0 {
            if hasSearched {
            cell.textLabel?.text = "No search returns"
            cell.detailTextLabel?.text = ""
            }
        } else {
        let searchResult = searchResults[indexPath.row]
        cell.textLabel?.text = searchResult.name
        cell.detailTextLabel?.text = searchResult.artistName
        
        }
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}

// End extensions

