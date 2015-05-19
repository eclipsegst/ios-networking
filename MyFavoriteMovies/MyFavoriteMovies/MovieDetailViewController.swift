//
//  MovieDetailViewController.swift
//  MyFavoriteMovies
//
//  Created by iOS Students on 5/18/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var unFavoriteButton: UIButton!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        // Get the shared URL session
        session = NSURLSession.sharedSession()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // TASK: Get favorite movies, then update the favorite buttons
        if let movie = movie {
            
            // 0. Setting some defaults
            posterImageView.image = UIImage(named: "film342.png")
            titleLabel.text = movie.title
            unFavoriteButton.hidden = true
            
            // 1. Set the parameters
            let methodParameters = [
                "api_key": appDelegate.apiKey,
                "session_id": appDelegate.sessionID!
            ]
            
            // 2. Build the URL
            let urlString = appDelegate.baseURLSecureString + "account/\(appDelegate.userID!)/favorite/movies" + appDelegate.escapedParameters(methodParameters)
            let url = NSURL(string: urlString)!
            
            // 3. Configure the request
            let request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            // 4. Make the request
            let task = session.dataTaskWithRequest(request) { data, response, downloadError in
                if let error = downloadError {
                    println("Cound not complete the request \(error)")
                } else {
                    
                    // 5. Parse the data
                    var parsingError: NSError? = nil
                    let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                    
                    // 6. Use the data
                    if let error = parsingError {
                        println(error)
                    } else {
                        if let results = parsedResult["result"] as? [[String : AnyObject]] {
                            var isFavorite = false
                            let movies = Movie.moviesFromResults(results)
                            
                            for movie in movies {
                                if movie.id == self.movie!.id {
                                    isFavorite = true
                                }
                            }
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                if isFavorite {
                                    self.favoriteButton.hidden = true
                                    self.unFavoriteButton.hidden = false
                                } else {
                                    self.favoriteButton.hidden = false
                                    self.unFavoriteButton.hidden = true
                                }
                            }
                        } else {
                            println("Cound not find results in \(parsedResult)")
                        }
                    }
                }
            }
            
            // 7. Start the request
            task.resume()
            
            // TASK: Get the poster image, then populate the image view
            if let posterPath = movie.posterPath {
                
                let baseURL = NSURL(string: appDelegate.config.baseImageURLString)!
                let url = baseURL.URLByAppendingPathComponent("w342").URLByAppendingPathComponent(posterPath)
                
                let request = NSURLRequest(URL: url)
                
                let task = session.dataTaskWithRequest(request) { data, response, downloadError in
                    
                    if let error = downloadError {
                        print(error)
                    } else {
                        
                        if let image = UIImage(data: data!) {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.posterImageView.image = image
                            }
                        }
                    }
                }
                
                task.resume()
            }
        }
    }
    
}
