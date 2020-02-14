//
//  HomeTableTableViewController.swift
//  Twitter
//
//  Created by Johann Olivares on 2/11/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class HomeTableTableViewController: UITableViewController {

    //creating variables to hold our tweets
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    
    let myRefereshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        
        myRefereshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefereshControl
    }

    @objc func loadTweets() {
        
        numberOfTweets = 20
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams, success:
            { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()//empties array
                
            //loop adds get data and puts it in the array
            for tweet in tweets {
                
                self.tweetArray.append(tweet)
            }
                
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                
        }, failure: { (Error) in
            print("could not retrieve tweets")
        })
    }
    
    func loadMoreTweets() {
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets = numberOfTweets + 20
        let myParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams, success:
            { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()//empties array
                
            //loop adds get data and puts it in the array
            for tweet in tweets {
                
                self.tweetArray.append(tweet)
            }
                
                self.tableView.reloadData()
                
        }, failure: { (Error) in
            print("could not retrieve tweets")
        })
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    
    //Logout Buttton set on Action
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        //assigning values to elements in cell
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary//extacting array containing name
        
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContentLabel.text = tweetArray[indexPath.row]["text"] as? String
        
        cell.screenName.text = user["screen_name"] as? String
        
        let imageUrl =  URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        return cell
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

}
