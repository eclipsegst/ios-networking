//
//  ViewController.swift
//  SleepInTheLibrary
//
//  Created by iOS Students on 5/15/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//
/*
* How does it work?
*
* 1. client sends a HTTP request to the server(flickr API) using the methods 'flickr.galleries.getPhotos'
* 2. server responds with JSON containing information about the photos in gallery
* 3. client stores the JSON then randomly picks the URL of an image in the gallery
* 4. client requests an image's data using the URL
* 5. client displays the image
* 6. (if the button is clicked, go back to step 1)
*/

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

    @IBOutlet weak var photoTitle: UILabel!
    
    @IBAction func touchRefreshButton(sender: UIButton) {
        getImageFromFlickr()
    }
    
//    @IBOutlet weak var photoImageView: UIImageView!
//    @IBOutlet weak var photoTitle: UILabel!
//    
//    @IBAction func touchRefreshButton(sender: UIButton) {
//        //        println("touch button")
//        //        photoTitle.text = "abc"
//        
//        getImageFromFlickr()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getImageFromFlickr() {
        
        /* 2 - API method arguments */
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "gallery_id": GALLERY_ID,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        /* 3 - Initialize session and url */
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4 - Initialize task for getting data */
        /* Grab the singleton instance of NSURLSession and create the URL and and instance of NSURLRequest*/
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                /* 5 - Success! Parse the data */
                var parsingError: NSError? = nil
                let parsedResult: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                
                if let photosDictionary = parsedResult.valueForKey("photos") as? NSDictionary {
                    if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
                        
                        /* 6 - Grab a single, random image */
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                        let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
                        
                        /* 7 - Get the image url and title */
                        let photoTitle = photoDictionary["title"] as? String
                        let imageUrlString = photoDictionary["url_m"] as? String
                        let imageURL = NSURL(string: imageUrlString!)
                        
                        /* 8 - If an image exists at the url, set the image and title */
                        if let imageData = NSData(contentsOfURL: imageURL!) {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.photoImageView.image = UIImage(data: imageData)
                                self.photoTitle.text = photoTitle
                            })
                        } else {
                            println("Image does not exist at \(imageURL)")
                        }
                    } else {
                        println("Cant find key 'photo' in \(photosDictionary)")
                    }
                } else {
                    println("Cant find key 'photos' in \(parsedResult)")
                }
            }
        }
        
        /* 9 - Resume (execute) the task */
        task.resume()
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    
}


