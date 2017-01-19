//
//  ViewController.swift
//  JSON
//
//  Created by Juan Alvarez on 2/11/15.
//  Copyright (c) 2015 Alvarez Productions. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        
        JSONDateFormatter.registerDateFormatter(dateFormatter, withKey: "TweetDateFormatter")
        
        if let jsonURL = Bundle.main.url(forResource: "tweets", withExtension: "json") {
            let tweets = JSONAdapter<Tweet>.objectsFromJSONFile(jsonURL)
            
            print(tweets)
        }
    }
}

struct Tweet: JSONMappable {
    let user: User
    let text: String
    let screenName: String
    let createdAt: Date?
    let favorited: Bool

    init(mapper: JSONMapper) {
        user = mapper.objectFor("user")!
        screenName = mapper.stringValueFor("user.screen_name")
        text = mapper.stringValueFor("text")
        createdAt = mapper.dateFromStringFor("created_at", withFormatterKey: "TweetDateFormatter")
        favorited = mapper.boolValueFor("favorited")
    }
}

struct User: JSONMappable {
    let name: String
    let idString: String
    let id: Int
    let createdAt: Date?
    var urls: [String] = []
    let defaultProfile: Bool
    let followersCount: Int
    let backgroundColor: UIColor?
    
    init(mapper: JSONMapper) {
        name = mapper.stringValueFor("name")
        idString = mapper.stringValueFor("id_str")
        id = mapper.intValueFor("id")
        defaultProfile = mapper.boolValueFor("default_profile")
        followersCount = mapper.intValueFor("followers_count")
        
        backgroundColor = mapper.transform("profile_background_color", block: { (value) -> UIColor? in
            return UIColor.fromHex(value)
        })
        
        createdAt = mapper.dateFromStringFor("created_at", withFormatterKey: "TweetDateFormatter")
    }
}



