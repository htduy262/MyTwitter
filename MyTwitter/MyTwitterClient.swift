//
//  MyTwitterClient.swift
//  MyTwitter
//
//  Created by Duy Huynh Thanh on 10/26/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import AFNetworking
import BDBOAuth1Manager


let twitterConsumerKey = "1rLyxAISH1s0wttnVP0t3c3gH"
let twitterConsumerSecret = "NTK9YLw0UFf2yB9BDtCB7sOxkeI6zYKo3GGZr2QxQ0ukmcUrqz"


enum RetweetStatus: String {
    case retweet = "retweet"
    case unretweet = "unretweet"
}

enum FavoriteStatus: String {
    case destroy = "destroy"
    case create = "create"
}


class MyTwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = MyTwitterClient(baseURL: NSURL(string: "https://api.twitter.com") as URL!, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        // Delete previous authorized information
        MyTwitterClient.sharedInstance?.logout()
        
        
        loginSuccess = success
        loginFailure = failure
        
        
        fetchRequestToken(withPath: "oauth/request_token", method: "POST", callbackURL: NSURL(string: "myTwitter://authentication") as URL!, scope: nil, success: { (requestToken) in
            
            let token:String = (requestToken?.token)!
            
            print("fetchRequestToken successful")
            print("token = \(token)")
            
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)")
            UIApplication.shared.open(url as! URL)
            
            }, failure: { (error) in
                
                print("fetchRequestToken failed")
                print("\(error?.localizedDescription)")
                
                self.loginFailure?(error!)
        })
    }
    
    func logout() {
        
        Profile.currentUser = nil
        deauthorize()
    }
    
    func checkLogin(url: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        
        if (url.contains("oauth_verifier")) {
            
            let requetToken = BDBOAuth1Credential(queryString: url)
            
            // Save REQUEST_TOKEN_URL
            let defaults = UserDefaults.standard
            defaults.set(url, forKey: "REQUEST_TOKEN")
            defaults.synchronize()
            
            fetchAccessToken(withPath: "/oauth/access_token", method: "POST", requestToken: requetToken, success: { (accessToken) in
                self.getCurrentAccount(success: { (user) in
                    
                    success()
                    
                    // Update profile information
                    Profile.currentUser = user
                    
                    }, failure: { (error) in
                        
                        failure(error)
                })
                })
            { (error) in
                print("error: \(error?.localizedDescription)")
                failure(error!)
            }
        }
        else {
            print("Url is incorrect")
            failure(NSError(domain: "", code: 0, userInfo: nil))
        }
        
    }
    
    func checkLoginCallBack(url: NSURL) {
        
        if (url.query?.contains("oauth_verifier"))! {

            let requetToken = BDBOAuth1Credential(queryString: url.query)
            
            // Save REQUEST_TOKEN_URL
            let defaults = UserDefaults.standard
            defaults.set(url.query, forKey: "REQUEST_TOKEN")
            defaults.synchronize()
            
            fetchAccessToken(withPath: "/oauth/access_token", method: "POST", requestToken: requetToken, success: { (accessToken) in
                self.getCurrentAccount(success: { (user) in
                    
                    self.loginSuccess?()
                    
                    // Update profile information
                    Profile.currentUser = user
                    
                    }, failure: { (error) in
                        
                        self.loginFailure?(error)
                })
                })
            { (error) in
                print("error: \(error?.localizedDescription)")
                self.loginFailure?(error!)
            }
        }
        else {
            print("User canceled authentication")
            self.loginFailure?(NSError(domain: "", code: 0, userInfo: nil))
        }
        
    }
    
    func getCurrentAccount(success: @escaping (Profile)->(), failure: @escaping (Error)->()) {
        
        self.get("1.1/account/verify_credentials.json", parameters: nil, success: { (task, response) in
            
            let userDictionary = response as! NSDictionary
            let user = Profile(dictionary: userDictionary)
            
            success(user)
            
            }, failure: { (task, error) in
                failure(error)
        })
    }
    
    func getHomeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        self.get("1.1/statuses/home_timeline.json", parameters: nil, success: { (task, response) in
            
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsArray(dictionaries: dictionaries)
            success(tweets)
            
        }, failure: { (task, error) in
                failure(error)
        })
    }
    
    func retweet(id: String, retweet: Bool, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        let retweet = retweet ? RetweetStatus.retweet : RetweetStatus.unretweet

        let urlString = "1.1/statuses/\(retweet.rawValue)/\(id).json"
        
        self.post(urlString, parameters: nil, constructingBodyWith: nil, success: { (task, response) in
            
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            print(dictionary)
            success(tweet)
            
            }, failure: { (task, error) in
                failure(error)
        })
    }
    
    func favorite(id: String, isFavorited: Bool, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        let isFavorited = isFavorited ? FavoriteStatus.create : FavoriteStatus.destroy
        
        let urlString = "1.1/favorites/\(isFavorited.rawValue).json?id=\(id)"
        
        let params = ["id": id]
        
        self.post(urlString, parameters: params, constructingBodyWith: nil, success: { (task, response) in
            
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            
            success(tweet)
            
            }, failure: { (task, error) in
                failure(error)
        })
        
    }
    
    func replyATweet(tweetId: String, status: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        let urlString = "1.1/statuses/update.json"
        
        let params = ["status": status, "in_reply_to_status_id": tweetId]
        
        self.post(urlString, parameters: params, success: { (task, response) in
            
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            
            success(tweet)
            
            }, failure: { (task, error) in
                failure(error)
        })
    }
    
    func updateTweet(status: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        let urlString = "1.1/statuses/update.json"
        
        let params = ["status": status]
        
        self.post(urlString, parameters: params, success: { (task, response) in
            
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            
            success(tweet)
            
            }, failure: { (task, error) in
                failure(error)
        })
    }
}
