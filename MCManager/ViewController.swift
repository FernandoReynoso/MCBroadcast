//
//  ViewController.swift
//  MCManager
//
//  Created by Fernando Reynoso on 6/8/15.
//  Copyright (c) 2015 Fernando Reynoso. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBroadcastDelegate {

    @IBOutlet var statusLabel:  UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var textField:    UITextField!
    
    var manager: MCBroadcast!
    var message: MCObject = MCObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.manager = MCBroadcast(displayName: UIDevice.currentDevice().name, delegate: self)
    
        self.message.text = "Hello World!"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.manager.startBrownsing()
        self.manager.startAdvertising()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        
        self.message.text = self.textField.text
        
        self.manager.sendObject(self.message, toBroadcasters: nil)
    }
    
    //MARK: MCBroadcast delegate
    
    func mcBroadcast(manager: MCBroadcast, broadcaster: MCBroadcaster, didChangeState state: MCBroadcastSessionState) {
        
        var status: String
        
        switch state {
            
        case .Connected:
            
            status = "Connected to \(broadcaster.displayName)"
            
            let toBroadcaster: [MCBroadcaster] = [broadcaster]
            
            self.manager.sendObject(self.message, toBroadcasters: toBroadcaster)
            break
            
        case .Connecting:
            
            status = "Connecting to \(broadcaster.displayName)"
            break
            
        case .NotConnected:
            
            status = "Not connected to \(broadcaster.displayName)"
            break
        }
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.statusLabel.text = status;
        }
    }
    
    func mcBroadcast(manager: MCBroadcast, didReceiveObject object: MCObject?, fromBroadcaster broadcaster: MCBroadcaster) {
        
        println("Message from: \(broadcaster.displayName)")
        println(object?.log())
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.messageLabel.text = object?.text as? String
        }
    }
    
    func mcBroadcast(manager: MCBroadcast, foundBroadcaster broadcaster: MCBroadcaster) {
        
    }
    
    func mcBroadcast(manager: MCBroadcast, lostBroadcaster broadcaster: MCBroadcaster) {
        
    }
    
    func mcBroadcast(manager: MCBroadcast, didReceiveInvitationFromBroadcaster broadcaster: MCBroadcaster) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.statusLabel.text = "Received invitation from \(broadcaster.displayName)";
        }
    }
    
    func mcBroadcast(manager: MCBroadcast, didAcceptInvitationFromBroadcaster broadcaster: MCBroadcaster) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.statusLabel.text = "Accepted invitation from \(broadcaster.displayName)";
        }
    }
    
    func mcBroadcast(manager: MCBroadcast, didEncounterError error: NSError) {
        
    }
}

