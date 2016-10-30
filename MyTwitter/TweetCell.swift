//
//  TweetCell.swift
//  MyTwitter
//
//  Created by Duy Huynh Thanh on 10/26/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import AFNetworking

class TweetCell: UITableViewCell {
    
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
    
    var tweet: Tweet! {
        didSet {
            
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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
