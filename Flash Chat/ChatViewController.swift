//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//
//  Modified by Seth Mosgin

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set yourself as the delegate and datasource
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        // Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        //Register your MessageCell.xib file (necessary process when using a custom design) here:
        //Nib is basically an old way to refer to xib. They are functionally the same
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    // Declare cellForRowAtIndexPath here:
    // What happens for each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        let messageArray = ["first msg", "second msg", "third msg"]
        
        cell.messageBody.text = messageArray[indexPath.row]
        
        return cell
    }
    
    // Declare numberOfRowsInSection here:
    // How many rows do we want in the tableview? Keep in mind that cells are reused once scrolled past and appended to the bottom to save resources,
    // so this question is in the context of how many rows should be visible/used at one time
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    // Declare tableViewTapped here:
    // Once the user taps outside of the keyboard (on the tableview), force end editing to animate closing the keyboard
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    // Declare configureTableView
    // Configure the height of the tableview so that the rows don't get squished. Should be adaptable to message length too
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    // Declare textFieldDidBeginEditing here:
    // Happens automatically when editing begins
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Animate updating of the message textfield view
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308 //height of keyboard (258) + height of view (50)
            self.view.layoutIfNeeded() //If something in the view has changed, redraw
        }
    }
    
    
    
    // Declare textFieldDidEndEditing here:
    // Needs to be forced
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50 //height of view after begin animation (308) - height of keyboard (258)
            self.view.layoutIfNeeded() //If something in the view has changed, redraw
        }

    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true) //Trigger animating closing the keyboard
        //TODO: Send the message to Firebase and save it in our database
        //Temporarily disable send so users don't attempt to send the same message twice while networking is happening
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text!]
        
        // Save our messagesDictionary in our messagesDB under an automatically generated id
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            } else {
                print("Message saved successfully!")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { (snapshot) in
            //We know that value is a dictionary, because we sent the message and stored it as a dictionary
            // Cast Any? to Dictionary of string keys with string values
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            print(text, sender)
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            
            //Pop back to the bottom of the stack of view controllers, i.e. the welcome screen
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error. There was a problem signing out.")
        }
        
    }
    


}
