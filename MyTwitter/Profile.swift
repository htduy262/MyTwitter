//
//  UserModel.swift
//  MyTwitter
//
//  Created by Duy Huynh Thanh on 10/26/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit

class Profile: NSObject {
    
    static let userDidLogoutNotification = "UserDidLogout"
    
    var dictionary: NSDictionary?
    
    var name: String?
    var screenName: String?
    var profileUrl: NSURL?
    var descriptionString: String?
    
    init(dictionary: NSDictionary) {
        
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = NSURL(string: profileUrlString)
        }
        
        descriptionString = dictionary["description"] as? String
    }
    
    static var _currentUser: Profile?
    
    class var currentUser: Profile? {
        
        get {
            
            return _currentUser
        }
        
        set (user) {
            
            _currentUser = user
        }
    }
}
