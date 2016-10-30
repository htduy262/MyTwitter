//
//  LoginViewController.swift
//  MyTwitter
//
//  Created by Duy Huynh Thanh on 10/26/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
            
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        
        MyTwitterClient.sharedInstance?.login(success: {
            
            print("Login successful")
            
            self.performSegue(withIdentifier: "afterLoginSegue", sender: self)
            
            }, failure: { (error: Error) in
                
                print("Login failed")
                print("\(error.localizedDescription)")
                
                let alertController = UIAlertController(title: "Oops!", message: "Ô nô.. Login failed. Please try again later!", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
                
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true, completion: nil)
        })
        
    }

}

