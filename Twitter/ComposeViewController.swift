//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Kyle Wilson on 2/13/16.
//  Copyright © 2016 Bluyam Inc. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet var composeTextView: UITextView!
    
    var isReply: Bool?
    var inReplyToTweetWithId: String?
    var startingText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        if isReply != nil {
            composeTextView.text = isReply! ? startingText : ""
        }
        else {
            composeTextView.text = ""
        }
        composeTextView.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onTweetPressed(sender: AnyObject) {
        let status = composeTextView.text
        if isReply != nil {
            if isReply! {
            TwitterClient.sharedInstance.tweet(status, params: ["in_reply_to_status_id": inReplyToTweetWithId!], completion: { (id) -> () in
                print("created tweet with id \(id)")
                })
            }
        }
        else {
            TwitterClient.sharedInstance.tweet(status, params: nil, completion: { (id) -> () in
                print("created tweet with id \(id)")
            })
        }
        dismissViewControllerAnimated(true, completion: nil)
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
