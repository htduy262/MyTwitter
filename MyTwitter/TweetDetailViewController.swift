//
//  TweetDetailViewController.swift
//  MyTwitter
//
//  Created by Duy Huynh Thanh on 10/28/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var textMessageLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    var tweet: Tweet!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        defaults.set(nil, forKey: "TWEET_ID")
        defaults.synchronize()
        
        loadTweet()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadTweet() {
        if tweet.profileImageUrl != nil {
            profileImage.alpha = 0
            profileImage.setImageWith(tweet.profileImageUrl! as URL)
            UIView.animate(withDuration: 0.3, animations: {
                self.profileImage.alpha = 1
            })
        } else {
            self.profileImage.image = UIImage(named: "user")
        }
        self.usernameLabel.text = tweet.username
        self.screennameLabel.text = "@\(tweet.screenname!)"
        self.textMessageLabel.text = tweet.text
        
        self.timerLabel.text = tweet.timeString()
        
        retweetCountLabel.text = "\(tweet.retweetCount)"
        favoriteCountLabel.text = "\(tweet.favoritesCount)"
        
        if tweet.retweeted {
            retweetButton.setImage(UIImage(named: "retweet_active"), for: .normal)
        }
        else {
            retweetButton.setImage(UIImage(named: "retweet"), for: .normal)
        }
        
        if tweet.favorited {
            favoriteButton.setImage(UIImage(named: "heart_active"), for: .normal)
        }
        else {
            favoriteButton.setImage(UIImage(named: "heart"), for: .normal)
        }
    }

    @IBAction func onReply(_ sender: UIButton) {
        
        defaults.set(tweet.id, forKey: "TWEET_ID")
        defaults.synchronize()
        
        //performSegue(withIdentifier: "ReplyTweetSegue", sender: self)
    }
    
    @IBAction func onRetweet(_ sender: UIButton) {
        MyTwitterClient.sharedInstance?.retweet(id: tweet.id, retweet: !tweet.retweeted, success: { (tweet) in
            
            self.tweet = tweet
            self.retweetCountLabel.text = "\(tweet.retweetCount)"
            
            if tweet.retweeted {
                self.retweetButton.setImage(UIImage(named: "retweet_active"), for: .normal)
            }
            else {
                self.retweetButton.setImage(UIImage(named: "retweet"), for: .normal)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func onFavorite(_ sender: UIButton) {
        MyTwitterClient.sharedInstance?.favorite(id: tweet.id, isFavorited: !tweet.favorited, success: { (tweet) in
            
            self.tweet = tweet
            self.favoriteCountLabel.text = "\(tweet.favoritesCount)"
            
            if tweet.favorited {
                self.favoriteButton.setImage(UIImage(named: "heart_active"), for: .normal)
            }
            else {
                self.favoriteButton.setImage(UIImage(named: "heart"), for: .normal)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func backHome(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
