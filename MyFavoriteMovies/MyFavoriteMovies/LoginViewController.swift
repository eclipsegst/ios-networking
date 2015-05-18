//
//  LoginViewController.swift
//  MyFavoriteMovies
//
//  Created by iOS Students on 5/18/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugTextLabel: UILabel!

    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        if usernameTextField.text.isEmpty {
            debugTextLabel.text = "Username Empty."
        } else if passwordTextField.text.isEmpty {
            debugTextLabel.text = "Password Empty."
        } else {
            // Steps for Authentication
            // Step 1: Create a new request token
            // Step 2: Ask the user for permission via the API ("login")
            // Step 3: Create a session ID
            
            // Extra Steps...
            // Step 4: Go ahead and get the user id
            // Step 5: Got everything we need, go to the next view
        }
        
        //self.getRequestToken()
    }
    
    // MARK: - Service Calls
    func getRequestToken() {
        // TASK: Get a request token, then store it (appDelegate.requestToken) and login with the token
        
        // 1. Set the parameters
        let methodParameters = [
            "key": "value"
        ]
        
        // 2. Build the URL
        let urlString = "BUILD_THE_URL" + appDelegate.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                println("getRequestToken: Print an error message")
            } else {
                // 5. Parse the data
                println("getRequestToken: Parse the data")
                // 6. Use the data
                println("getRequestToken: Use the data")
            }
        }
        
        // 7. Start the request
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
