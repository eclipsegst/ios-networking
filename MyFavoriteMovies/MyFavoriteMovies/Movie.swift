//
//  Movie.swift
//  MyFavoriteMovies
//
//  Created by iOS Students on 5/18/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

struct Movie {
    
    var title = ""
    var id = 0
    var posterPath: String? = nil
    
    init(dictionary: [String : AnyObject]) {
        title = dictionary["title"] as! String
        id = dictionary["id"] as! Int
        posterPath = dictionary["poster_path"] as? String
    }
    
    static func moviesFromResults(results: [[String : AnyObject]]) -> [Movie] {
        
        var movies = [Movie]()
        
        // Iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            movies.append(Movie(dictionary: result))
        }
        
        return movies
    }
}
