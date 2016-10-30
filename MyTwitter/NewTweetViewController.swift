//
//  NewTweetViewController.swift
//  MyTwitter
//
//  Created by Duy Huynh Thanh on 10/29/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit

class NewTweetViewController: UIViewController {

    let MAX_LETTER_COUNT = 140
    
    @IBOutlet weak var newTweetTextfield: UITextView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    
    var tweet: Tweet?
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let user = Profile.currentUser {
            profileImage.setImageWith(user.profileUrl! as URL)
            usernameLabel.text = user.name
            screennameLabel.text = user.screenName
        }
        
        newTweetTextfield.text = "What's happening?"
        newTweetTextfield.textColor = UIColor.lightGray
        newTweetTextfield.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTweet(_ sender: UIBarButtonItem) {
        
        if let tweetId = defaults.object(forKey: "TWEET_ID") as? String {
            
            let status = "@\(screennameLabel.text!) \(self.newTweetTextfield.text!)"
            
            MyTwitterClient.sharedInstance?.replyATweet(tweetId: tweetId , status: status, success: { (tweet) in
                
                self.tweet = tweet
                
                self.dismiss(animated: true, completion: nil)
                
                }, failure: { (error) in
                    
                    print(error.localizedDescription)
                    
                    let alertController = UIAlertController(title: "Oops!", message: "Ô nô.. There something wrong. Please try again later!", preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
                    
                    alertController.addAction(OKAction)
                    
                    self.present(alertController, animated: true, completion: nil)
            })
            
            defaults.set(nil, forKey: "TWEET_ID")
            defaults.synchronize()
        } else {
            
            MyTwitterClient.sharedInstance?.updateTweet(status: self.newTweetTextfield.text!, success: { (tweet) in
                
                let nav = self.navigationController!
                let tweetsNav = nav.presentingViewController! as! UINavigationController
                if let tweetsViewController = tweetsNav.topViewController as? TweetsViewController {
                    tweetsViewController.insertTweet(tweet: tweet)
                }
                
                self.dismiss(animated: true, completion: nil)
            }) { (error) in
                
                print(error.localizedDescription)
                
                let alertController = UIAlertController(title: "Oops!", message: "Ô nô.. There something wrong. Please try again later!", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
                
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension NewTweetViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "What\'s happening?" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "What's happening?"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = newTweetTextfield.text!.utf16.count + text.utf16.count - range.length
        let currentText:NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        
        if updatedText.isEmpty {
            textView.text = "What's happening?"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            self.countdownLabel.text = "\(MAX_LETTER_COUNT)"
            
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = text
            textView.textColor = UIColor.black
            self.countdownLabel.text = "\(MAX_LETTER_COUNT - 1)"
        } else{
            if newLength <= MAX_LETTER_COUNT {
                self.countdownLabel.text = "\(MAX_LETTER_COUNT - newLength)"
                return true
            }
        }
        return false
    }
}
