//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by iOS Students on 5/19/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var headerTextLabel: UILabel!
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.debugTextLabel.text = ""
    }

    // MARK: - Actions
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        // NEW steps for Authentication...
        // Step 1: Create a new request token
        // Step 2: Ask the user for permission via the website
        // Step 3: Creae a session ID
        // Step 4: Get the user id
        
        self.getRequestToken()
    }
    
    // MARK: - Service Calls
    
    func getRequestToken() {
        
        /* TASK: Get a request token, then store it (appDelegate.requestToken) and login with the token */
        
        /* 1. Set the parameters */
        let methodParameters = [
            "api_key": appDelegate.apiKey
        ]
        
        /* 2. Build the URL */
        let urlString = appDelegate.baseURLSecureString + "authentication/token/new" + appDelegate.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Login Failed (Request Token)."
                }
                println("Could not complete the request \(error)")
            } else {
                
                /* 5. Parse the data */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* 6. Use the data! */
                if let requestToken = parsedResult["request_token"] as? String {
                    self.appDelegate.requestToken = requestToken
                    self.loginWithToken(self.appDelegate.requestToken, hostViewController: self, completionHandler: { (success, errorString) -> Void in
                        if success {
                            self.getSessionID(self.appDelegate.requestToken!)
                        } else {
                            self.debugTextLabel.text = "Login Failed (Login Step)."
                        }
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Login Failed (Request Token)."
                    }
                    println("Could not find request_token in \(parsedResult)")
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    /* This function opens a TMDBAuthViewController to handle Step 2a of the auth flow */
    func loginWithToken(requestToken: String?, hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let authorizationURL = NSURL(string: "\(TMDBClient.Constants.AuthorizationURL)\(requestToken!)")
        let request = NSURLRequest(URL: authorizationURL!)
        let webAuthViewController = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("TMDBAuthViewController") as! TMDBAuthViewController
        webAuthViewController.urlRequest = request
        webAuthViewController.requestToken = requestToken
        webAuthViewController.completionHandler = completionHandler
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
        
        dispatch_async(dispatch_get_main_queue(), {
            hostViewController.presentViewController(webAuthNavigationController, animated: true, completion: nil)
        })
    }
    
    func getSessionID(requestToken: String) {
        
        /* 1. Set the parameters */
        let methodParameters = [
            "api_key": appDelegate.apiKey,
            "request_token": requestToken
        ]
        
        /* 2. Build the URL */
        let urlString = appDelegate.baseURLSecureString + "authentication/session/new" + appDelegate.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Login Failed (Session ID)."
                }
                println("Could not complete the request \(error)")
            } else {
                
                /* 5. Parse the data */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* 6. Use the data! */
                if let sessionID = parsedResult["session_id"] as? String {
                    self.appDelegate.sessionID = sessionID
                    self.getUserID(self.appDelegate.sessionID!)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Login Failed (Session ID)."
                    }
                    println("Could not find session_id in \(parsedResult)")
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    func getUserID(session_id : String) {
        
        /* TASK: Get the user's ID, then store it (appDelegate.userID) for future use and go to next view! */
        
        /* 1. Set the parameters */
        let methodParameters = [
            "api_key": appDelegate.apiKey,
            "session_id": session_id
        ]
        
        /* 2. Build the URL */
        let urlString = appDelegate.baseURLSecureString + "account" + appDelegate.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Login Failed (User ID)."
                }
                println("Could not complete the request \(error)")
            } else {
                
                /* 5. Parse the data */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* 6. Use the data! */
                if let userID = parsedResult["id"] as? Int {
                    self.appDelegate.userID = userID
                    self.completeLogin()
                    
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Login Failed (User ID)."
                    }
                    println("Could not find id in \(parsedResult)")
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    // MARK: - LoginViewController
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugTextLabel.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.debugTextLabel.text = errorString
            }
        })
    }


}
