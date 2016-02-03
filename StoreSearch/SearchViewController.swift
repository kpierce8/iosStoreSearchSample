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
    
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        tableView.rowHeight = 80
        searchBar.becomeFirstResponder()    
    }

    
    func urlWithSearchText(searchText: String) -> NSURL {
        
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }
    
    func performStoreRequestWithURL(url: NSURL) -> String? {
        do {
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch {
            print("Download error: \(error)")
            return nil
        }
    }
    
    func parseJSON(jsonString: String) -> [String: AnyObject]? {
        guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
            else { return nil }
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error  '\(error)'")
            return nil
        }
    }
    
    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
        guard let array = dictionary["results"] as? [AnyObject] else {
            print("expected results array")
            return []
        }
        
        var searchResults = [SearchResult]()
        for resultDict in array {
            
            var searchResult: SearchResult?
            if let wrapperType = resultDict["wrapperType"] as? String {
            switch wrapperType {
                case "track":
                    searchResult = parseTrack(resultDict)
                default:
                    break
                }
            }
            if let result = searchResult {
                searchResults.append(result)
            }
        }
        return searchResults
    }
    
    
    func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showNetworkError() {
        let alert = UIAlertController(title: "whoops..", message: "error from the itunes store", preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil )
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }

} // End class


//SearchBar Extension
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            
        searchBar.resignFirstResponder()
        hasSearched = true
       
        searchResults = [SearchResult]()
        
            let url = urlWithSearchText(searchBar.text!)
            print("URL: '\(url)")
            if let jsonString = performStoreRequestWithURL(url){
                print("Received JSON string '\(jsonString)'")
            
                if let dictionary = parseJSON(jsonString){
                    print("Dictionary \(dictionary)")
                    parseDictionary(dictionary)
                    tableView.reloadData()
                    return
                }
            }
//                   showNetworkError()
        }
  
    }
    
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    
}

//TableView dataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if !hasSearched {
            return 0
        } else
        
        if searchResults.count == 0 {
            return 1
        } else {
        return searchResults.count
        }
    }
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       if searchResults.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath:  indexPath)
        } else {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
        let searchResult = searchResults[indexPath.row]
        cell.nameLabel.text = searchResult.name
        cell.artistNameLabel.text = searchResult.artistName
        return cell
        
            }
    }
}

//Tableview Delegate
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

