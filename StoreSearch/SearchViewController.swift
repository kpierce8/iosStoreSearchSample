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
        var isLoading = false
    var dataTask: NSURLSessionDataTask?
    
    
       @IBOutlet weak var searchBar: UISearchBar!
       @IBOutlet weak var tableView: UITableView!
       @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        performSearch()
    }
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0)
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)

        tableView.rowHeight = 80
        searchBar.becomeFirstResponder()    
    }

    
    func urlWithSearchText(searchText: String, category: Int) -> NSURL {
        let entityName: String
        switch category {
            case 1: entityName = "musicTrack"
            case 2: entityName = "software"
            case 3: entityName = "ebook"
            default: entityName = ""

        }
        
        
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = NSURL(string: urlString)
        return url!
    }
    

    
    func parseJSON(data: NSData) -> [String: AnyObject]? {
       
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
                    searchResult = parseTrack(resultDict as! [String : AnyObject])
            case "audiobook":
                searchResult = parseAudioBook(resultDict as! [String : AnyObject])
            case "software":
                searchResult = parseSoftware(resultDict as! [String : AnyObject])
            default:
                    break
                }
            } else if let kind = resultDict["kind"] as? String where kind == "ebook" {
                searchResult = parseEBook(resultDict as! [String: AnyObject])
            }
            if let result = searchResult {
                searchResults.append(result)
            }
        }
        return searchResults
    }
    
    
        
    func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String

        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    
    func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }

    func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genres: AnyObject = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
        }
        return searchResult
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if segue.identifier == "ShowDetail" {
            let detailController = segue.destinationViewController as! DetailViewController
         
             let indexPath = sender as! NSIndexPath
            let searchResult = searchResults[indexPath.row] as SearchResult
            detailController.searchResult = searchResult
            //   detailController.artistNameLabel.text = searchResult.artistName
         //   detailController.nameLabel.text = searchResult.name
         //   detailController.kindLabel.text = searchResult.kind
            
         //   detailController.genreLabel.text = searchResult.genre
         //   detailController.priceButton.titleLabel?.text = String(format: "%@",searchResult.price)
        }
    }

    
} // End class


//SearchBar Extension
extension SearchViewController: UISearchBarDelegate {

        func searchBarSearchButtonClicked(searchBar: UISearchBar) {
            performSearch()
    }
    
    
    
    func performSearch() {
        if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()
            
        dataTask?.cancel()
        isLoading = true
        tableView.reloadData()
        hasSearched = true
        searchResults = [SearchResult]()
        
            let url = self.urlWithSearchText(searchBar.text!, category: segmentedControl.selectedSegmentIndex)
           
         let session = NSURLSession.sharedSession()
            
             dataTask = session.dataTaskWithURL(url, completionHandler: {
                data, response, error in
                if let error = error where error.code == -999 {
                    return 
                } else if let httpResponse = response as? NSHTTPURLResponse
                    where httpResponse.statusCode == 200 {
                        if let data = data, dictionary = self.parseJSON(data) {
                            self.searchResults =  self.parseDictionary(dictionary)
                            self.searchResults.sortInPlace(<)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.isLoading = false
                                self.tableView.reloadData()
                            }
                            return
                        }
                        
                } else {
                     print("failure! \(response!)")
                }
                   dispatch_async(dispatch_get_main_queue()) {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
            })
        dataTask?.resume()
        }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    
}

//TableView dataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else
        
        if searchResults.count == 0 {
            return 1
        } else {
        return searchResults.count
        }
    }
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if isLoading {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
        
        let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
        spinner.startAnimating()
        return cell
    }
    
       if searchResults.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath:  indexPath)
        } else {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
        let searchResult = searchResults[indexPath.row]
        cell.configureForSearchResult(searchResult)
        return cell
        
            }
    }
}

//Tableview Delegate
extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
    }

// End extensions

