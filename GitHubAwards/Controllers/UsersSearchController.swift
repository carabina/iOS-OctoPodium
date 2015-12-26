//
//  UsersSearchController.swift
//  GitHubAwards
//
//  Created by Nuno Gonçalves on 26/11/15.
//  Copyright © 2015 Nuno Gonçalves. All rights reserved.
//

import UIKit

class UsersSearchController: UIViewController {
   
    @IBOutlet weak var resultsScroll: UIScrollView!
    @IBOutlet weak var searchField: SearchBar!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userLoginLabel: UILabel!
    
    var searchingLabel: UILabel!

    var user: User?
    
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.searchDelegate = self
        searchingLabel = UILabel(frame: CGRectMake(10, 20, resultsScroll.frame.width - 20, 20))
        searchingLabel.textColor = .whiteColor()
        resultsScroll.addSubview(searchingLabel)
        resultsScroll.contentSize = CGSizeMake(resultsScroll.frame.size.width, CGFloat(20));
    }

    private func restartTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(
            0.5,
            target: self,
            selector: "refreshSearchingLabel",
            userInfo: nil,
            repeats: true
        )
    }
    
    var points = 0
    
    @objc private func refreshSearchingLabel() {
        points += 1
        if points > 3 { points = 0 }
        searchingLabel.text = "Searching\(String(count: points, repeatedValue: Character(".")))"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UsersSearchToDetailSegue" {
            let vc = segue.destinationViewController as! UserDetailsController
            if let user = user {
                vc.user = user
            }
        }
    }
    
    private func searchUserFor(login: String) {
        showLoadingIndicatior()
        GetUser(login: login).fetch(gotUser, failure: failedToSearchForUser)
    }
    
    private func gotUser(user: User) {
        addLabelToScroll("Found user \(searchField.text!)")
        userLoginLabel.text = user.login!
        self.user = user
        ImageLoader.fetchAndLoad(user.avatarUrl!, imageView: avatarImageView)
        stopLoadingIndicator()
    }
    
    var numberOfSubviews = 2
    private func addLabelToScroll(text: String) {
        let label = UILabel(frame: CGRectMake(10, CGFloat(20 * numberOfSubviews), resultsScroll.frame.width - 20, 20))
        label.text = text
        label.textColor = .whiteColor()
        resultsScroll.addSubview(label)
        resultsScroll.contentSize = CGSizeMake(resultsScroll.frame.size.width, CGFloat(20 * (numberOfSubviews + 1)));
        numberOfSubviews += 1
        
        if resultsScroll.contentSize.height > resultsScroll.bounds.size.height {
            let bottomOffset = CGPointMake(0, resultsScroll.contentSize.height - resultsScroll.bounds.size.height);
            resultsScroll.setContentOffset(bottomOffset, animated: true)
        }
        
    }
    
    private func failedToSearchForUser() {
        NotifyError.display()
        stopLoadingIndicator()
    }
    
    private func showLoadingIndicatior() {
        restartTimer()
    }
    
    private func stopLoadingIndicator() {
        timer?.invalidate()
        timer = nil
    }
}

extension UsersSearchController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        
        if text.characters.count > 2 {
            searchUserFor(text)
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.resignFirstResponder()
        }
    }
}