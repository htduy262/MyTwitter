//
//  Tweet.swift
//  MyTwitter
//
//  Created by Duy Huynh Thanh on 10/26/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var username: String?
    var screenname: String?
    var profileImageUrl: NSURL?
    
    var id: String
    var text: String?
    var timestamp : NSDate?
    
    var retweeted = false
    var retweetCount = 0
    var favorited = false
    var favoritesCount = 0
    
    init(dictionary: NSDictionary) {
        
        username = dictionary.value(forKeyPath: "user.name") as? String
        screenname = dictionary.value(forKeyPath: "user.screen_name") as? String
        if let url = dictionary.value(forKeyPath: "user.profile_image_url_https") as? String {
            profileImageUrl = NSURL(string: url)
        }
        
        id = dictionary["id_str"] as! String
        text = dictionary["text"] as? String
        
        let timestampString = dictionary["created_at"] as? String
        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)! as NSDate?
        }
        
        retweeted = dictionary["retweeted"] as? Bool ?? false
        retweetCount = dictionary["retweet_count"] as? Int ?? 0
        
        if dictionary["retweeted_status"] != nil {
            favorited = dictionary.value(forKeyPath: "retweeted_status.favorited") as? Bool ?? false
            favoritesCount = dictionary.value(forKeyPath: "retweeted_status.favorite_count") as? Int ?? 0
        }
        else {
            favorited = dictionary["favorited"] as? Bool ?? false
            favoritesCount = dictionary["favorite_count"] as? Int ?? 0
        }
    }
    
    static func tweetsArray(dictionaries: [NSDictionary]) -> [Tweet] {
        
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
    
    func timeString() -> String {
        return timeAgo(sinceDate: self.timestamp!, numericDates: true) ?? ""
    }
    
    func timeAgo(sinceDate date:NSDate, numericDates:Bool) -> String? {
        let calendar = NSCalendar.current
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date as Date : now as Date
        
        let components:DateComponents = calendar.dateComponents([.second, .minute, .hour, .day, .weekOfYear, .month, . year], from: earliest as Date, to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!)y"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1y"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1m"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!)w"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1w"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) d"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1d"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) h"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1h"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            // minutes ago
            return "\(components.minute!) mi"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 mi"
            } else {
                return "A mi"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!)s"
        } else {
            return "Now"
        }
    }
}
