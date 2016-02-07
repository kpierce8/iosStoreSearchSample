//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by UberDominator on 2/6/16.
//  Copyright © 2016 Frantic Goose Applications. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var searchResult: SearchResult!
    var downloadTask: NSURLSessionDownloadTask?
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
      
    @IBAction func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func openInStore () {
        if let url = NSURL(string: searchResult.storeURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        
        popupView.layer.cornerRadius = 10
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        updateUI(searchResult)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    func updateUI(result: SearchResult){
        nameLabel.text = result.name
        artistNameLabel.text = result.artistName
        kindLabel.text = result.kindForDisplay()
        genreLabel.text = result.genre
        //priceButton.titleLabel?.text = String(format: "%@", result.price)
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = searchResult.currency
        let priceText: String
        
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.stringFromNumber(searchResult.price) {
            priceText = text
        } else {
            priceText = ""
        }
        
        priceButton.setTitle(priceText, forState: .Normal)
    
        if let url = NSURL(string: searchResult.artworkURL100) {
            downloadTask = artworkImageView.loadImageWithURL(url)
        }
    }
    
    deinit {
        print("deinit \(self)")
        downloadTask?.cancel()
    }
    
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented,
                                            presentingViewController: presenting)
    }
}


extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}