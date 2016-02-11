//
//  TwitterClient.swift
//  Twitter
//
//  Created by Kyle Wilson on 2/9/16.
//  Copyright © 2016 Bluyam Inc. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "uEGBWYu73NSjORz9W7Dnc2KVE"
let twitterConsumerSecret = "P8Mo6GO5cXYb2SVMTXUmsobXUFqMCDAA1R4KrPlfmnPyOQbpVp"
let twitterBaseUrl = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseUrl, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        
        return Static.instance
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        // getting timeline data
        GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //print("home timeline: \(response)")
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                print("There was an error getting the home timeline: \(error.description)")
                completion(tweets: nil, error: error)
        })
    
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken() // returns the user to a logged-out state, which is assumed in the following steps
        // Step 1: Get Request Token
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestCredential: BDBOAuth1Credential!) -> Void in
            print("Got the request credential: \(requestCredential.token)")
            // Step 2: Build Authorization Page URL with Token
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestCredential.token!)")!
            // (Outside of this code) Set up app to handle the callbackURL from the token request
            // This is where Twitter will redirect you after the authorization is complete (we want to go back to our app)
            UIApplication.sharedApplication().openURL(authURL)
        }) { (error: NSError!) -> Void in
            print("There was an error getting the request credentials: \(error.description)")
            self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openUrl(url: NSURL) {
        // Step 3: Get the access token
        TwitterClient.sharedInstance.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken:BDBOAuth1Credential!) -> Void in
            print("Got access token: \(accessToken)")
            
            // initial endpoint hit
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
                // print("user: \(response)")
                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                self.loginCompletion?(user: user, error: nil)
                print("user: \(user.name!)")
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                print("There was an error getting the user: \(error.description)")
                self.loginCompletion?(user: nil, error: error)
            })
            

            
            }) { (error: NSError!) -> Void in
                print("There was an error getting the access token: \(error.description)")
        }

    }
}
