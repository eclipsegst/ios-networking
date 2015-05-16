//
//  ViewController.swift
//  FlickFinder
//
//  Created by iOS Students on 5/16/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.galleries.getPhotos"
    let API_KEY = "4f0751e10b9484ba6bf492246cb44aab"
    let GALLERY_ID = "5704-72157622566655097"
    let EXTRAS = "url_m"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var defaultLabel: UILabel!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    

    @IBAction func searchPhotosByPhraseButtonTouchUp(sender: AnyObject) {
        
        println("test search button 1")
        
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "gallery_id": GALLERY_ID,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        getImageFromFlickBySearch(methodArguments)
        
    }

    
    @IBAction func searchPhotosByLatLonButtonTouchUp(sender: AnyObject) {
        println("test search button 2")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    func getImageFromFlickBySearch(methodArguments: [String : AnyObject]) {
    
        // Get the shared NSURLSession to faciliate network activity
        let session = NSURLSession.sharedSession()
        
        // Create the NSURLRequest using properly escaped URL
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        // Create NSURLSessionDataTask and completion handler
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                println(parsedResult.valueForKey("photos"))
                
                // Get the photos dictionary
                if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] {

                    // Determine the total number of photos
                    var totalPhotosVal = 0
                    if let totalPhotos = photosDictionary["total"] as? Int {
                        totalPhotosVal = totalPhotos
                    }
                    
                    println("totalPhotosVal = \(totalPhotosVal)")
                    
                    // Grab a photo if photos are returned
                    if totalPhotosVal > 0 {
                        if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                            
                            // Get a random index, and pick a random photo's dictionary
                            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                            let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                            
                            // Prepare the UI updates
                            let photoTitle = photoDictionary["title"] as? String
                            let imageUrlString = photoDictionary["url_m"] as? String
                            let imageURL = NSURL(string: imageUrlString!)
                            
                            // Update the UI on the main thread
                            if let imageData = NSData(contentsOfURL: imageURL!) {
                                dispatch_async(dispatch_get_main_queue(), {
                                    println("Success, update the UI here...")
                                    self.photoImageView.image = UIImage(data: imageData)
                                    self.photoTitleLabel.text = photoTitle
                                    self.defaultLabel.text = ""
                                })
                            } else {
                                println("Image does not exist at \(imageURL)")
                            }
                        } else {
                            println("Cannot find key 'photo' in \(photosDictionary)")
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            println("Failure, update the UI here...")
                        })
                    }
                } else {
                    println("Cannot find key 'photos' in \(parsedResult)")
                }
            }
        }
        
        // Resume (execute) the task
        task.resume()
    
    }
    
    // Helper function: Given a dictionary of parameters, convert to a string for a url
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
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

