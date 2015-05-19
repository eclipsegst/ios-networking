//
//  FavoritesTableViewController.swift
//  MyFavoriteMovies
//
//  Created by iOS Students on 5/19/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var movies: [Movie] = [Movie]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Get the shared URL session
        session = NSURLSession.sharedSession()
        
        // Create and set the logout button
         self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Reply, target: self, action: "logoutButtonTouchUp")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // TASK: Get movies from favorite list, then populate the table
        
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
                println(error)
            } else {
                
                // 5. Parse the data
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                // 6. Use the data
                if let error = parsingError {
                    println("Could not parse the data \(error)")
                } else {
                    if let results = parsedResult["results"] as? [[String : AnyObject]] {
                        self.movies = Movie.moviesFromResults(results)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                        }
                    } else {
                        println("Could not find results in \(parsedResult)")
                    }
                }
            }
        }
        
        // 7. Start the request
        task.resume()
    }
    
    // MARK: - Logout
    
    func logoutButtonTouchUp() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get cell type
        let cellReuseIdentifier = "FavoriteTableViewCell"
        let movie = movies[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell

        // Set cell defaults
        cell.textLabel!.text = movie.title
        cell.imageView!.image = UIImage(named: "Film Icon")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        // TASK: Get the poster image, then populate the image view
        if let posterPath = movie.posterPath {
            let baseURL = NSURL(string: appDelegate.config.baseImageURLString)!
            let url = baseURL.URLByAppendingPathComponent("w154").URLByAppendingPathComponent(posterPath)
            
            let request = NSURLRequest(URL: url)
            
            let task = session.dataTaskWithRequest(request) { data, response, downloadError in
                if let error = downloadError {
                    println(error)
                } else {
                    
                    if let image = UIImage(data: data!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.imageView!.image = image
                        }
                    }
                }
            }
            
            task.resume()
            
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Push the movie detail view
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MovieDetailViewController") as! MovieDetailViewController
        controller.movie = movies[indexPath.row]
        self.navigationController!.pushViewController(controller, animated: true)
    }

    

}
