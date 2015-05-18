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
        
        // Get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        // Get the shared URL session
        session = NSURLSession.sharedSession()
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
        
        self.getRequestToken()
    }
    
    // MARK: - Service Calls
    func getRequestToken() {
        // TASK: Get a request token, then store it (appDelegate.requestToken) and login with the token

        // 1. Set the parameters
        let methodParameters = [
            "api_key": appDelegate.apiKey
        ]
        
        // 2. Build the URL
        let urlString = appDelegate.baseURLString + "authentication/token/new" + appDelegate.escapedParameters(methodParameters)

        let url = NSURL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Login Failed (Request Token)."
                }
                println("getRequestToken: Print an error message. \(error)")
            } else {
                // 5. Parse the data
                println("getRequestToken: Parse the data")
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                // 6. Use the data
                println("getRequestToken: Use the data")
                if let requestToken = parsedResult["request_token"] as? String {
                    self.appDelegate.requestToken = requestToken
                    println("gotRequestToken: \(requestToken)")
                    self.loginWithToken(self.appDelegate.requestToken!)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Login Failed (Request Token)."
                    }
                    println("Could not find request_token in \(parsedResult)")
                }
            }
        }
        
        // 7. Start the request
        task.resume()
    }
    
    func loginWithToken(requestToken: String) {
        
        // TASK: Login, then get a session id
        
        // 1. Set the parameters
        let methodParameters = [
            "api_key": appDelegate.apiKey,
            "request_token": requestToken,
            "username": self.usernameTextField.text,
            "password": self.passwordTextField.text
        ]
        
        // 2. Build the URL
        let urlString = appDelegate.baseURLString + "authentication/token/validate_with_login" + appDelegate.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // 4. Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Login Failed (Login Step)."
                }
                println("Could not complete the request \(error)")
            } else {
                // 5. Parse the data
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                // 6. Use the data
                if let success = parsedResult["success"] as? Bool {
                    if success {
                        
                        self.getSessionID(self.appDelegate.requestToken!)
                        
                    } else {
                        println("Login failed. Cannot find success in \(parsedResult)")
                    }
                } else {
                    if let status_code = parsedResult["status_code"] as? Int {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.debugTextLabel.text = parsedResult["status_message"] as? String
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.debugTextLabel.text = "Login Failed (Login Step)."
                        }
                        println("Could not find status_code in \(parsedResult)")
                    }
                }
            }
        }
        
        // 7. Start the request
        task.resume()
    }

    func getSessionID(requestToken: String) {
        
        // 1. Set the parameters
        let methodParameters = [
            "api_key": appDelegate.apiKey,
            "request_token": requestToken
        ]
        
        // 2. Build the URL
        let urlString = appDelegate.baseURLString + "authentication/session/new" + appDelegate.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Login Failed (Session ID)."
                }
                println("Could not complete the request \(error)")
            } else {
                // 5. Parse the data
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                // 6. Use the data
                if let sessionID = parsedResult["session_id"] as? String {
                    self.appDelegate.sessionID = sessionID
                    self.getUserID(self.appDelegate.sessionID!)
                    println("getSessionID: \(sessionID)")
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Login Failed (Session ID)."
                    }
                    println("Could not find session_id in \(parsedResult)")
                }
            }
        }
        
        // 7. Start the request
        task.resume()
        
    }
    
    func getUserID(session_id : String) {
        
        // 1. Set the parameters
        let methodParameters = [
            "api_key": appDelegate.apiKey,
            "session_id": session_id
        ]
        
        // 2. Build the URL
        let urlString = appDelegate.baseURLSecureString + "account" + appDelegate.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = " Login Failed (User ID)"
                }
                println("Could not complete the request \(error)")
            } else {
                
                // 5. Parse the data
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                // 6. Use the data
                if let userID = parsedResult["id"] as? Int {
                    self.appDelegate.userID = userID
                    self.completeLogin()
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Login Failed (User ID)"
                    }
                    println("Could not find id \(parsedResult)")
                }
            }
        }
        
        // 7. Start the request
        task.resume()
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue()) {
            self.debugTextLabel.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MoviesTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }
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
