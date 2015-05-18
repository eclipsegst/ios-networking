//
//  AppDelegate.swift
//  MyFavoriteMovies
//
//  Created by iOS Students on 5/18/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Constants for TheMovieDB
    let apiKey = "84033d2b557db0b55b8b9b8d50f41e87"
    let baseURLString = "http://api.themoviedb.org/3/"
    let baseURLSecureString = "https://api.themoviedb.org/3/"
    
    // Need these for login
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    
    // Configuration for TheMovieDB
    var config = Config()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Update the configuration if necessary
        config.updateIfDaysSinceUpdateExceeds(7)
        
        return true
    }
}

// MARK: - Helper
extension AppDelegate {
    // Helper function: Given a dictionary of parameters, convert to a string for a url
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key,value) in parameters {
            
            // Make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
}
