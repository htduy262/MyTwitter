//
//  TweetsViewController.swift
//  MyTwitter
//
//  Created by Duy Huynh Thanh on 10/29/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets = [Tweet]()
    var myTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loadHomeTimeline()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nextViewController = segue.destination as? TweetDetailViewController {
            let indexPath = tableView.indexPathForSelectedRow
            let currentTweet = tweets[indexPath!.row]
            nextViewController.tweet = currentTweet
        }
    }

    @IBAction func onLogout(_ sender: UIBarButtonItem) {
        MyTwitterClient.sharedInstance?.logout()
        
        print("Logout successful")
        
        dismiss(animated: true, completion: nil)
    }
    
    func loadHomeTimeline(){
        MyTwitterClient.sharedInstance?.getHomeTimeline(success: { (tweets) in
            self.tweets = tweets
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func insertTweet(tweet: Tweet) {
        self.tweets.insert(tweet, at: 0)
        self.tableView.reloadData()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadHomeTimeline()
        refreshControl.endRefreshing()
    }
    
    @IBAction func onNewTweet(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "TWEET_ID")
        defaults.synchronize()
    }
    
    
}

extension TweetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }
}
