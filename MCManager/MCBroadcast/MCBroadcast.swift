//
//  MCBroadcast.swift
//  MCBroadcast
//
//  Created by Fernando Reynoso on 6/8/15.
//  Copyright (c) 2015 Fernando Reynoso. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MCBroadcaster: NSObject {

    var peerId: MCPeerID
    var displayName: String { return self.peerId.displayName }
    
    init(peerID: MCPeerID) {
        
        self.peerId = peerID
        
        super.init()
    }
}

enum MCBroadcastSessionState: Int {
    case NotConnected
    case Connecting
    case Connected
}

protocol MCBroadcastDelegate {
    
    func mcBroadcast(manager: MCBroadcast, didReceiveObject object: MCObject?, fromBroadcaster broadcaster: MCBroadcaster)
    func mcBroadcast(manager: MCBroadcast, didEncounterError error: NSError)
    func mcBroadcast(manager: MCBroadcast, foundBroadcaster broadcaster: MCBroadcaster)
    func mcBroadcast(manager: MCBroadcast, lostBroadcaster broadcaster: MCBroadcaster)
    func mcBroadcast(manager: MCBroadcast, broadcaster: MCBroadcaster, didChangeState state: MCBroadcastSessionState)
    func mcBroadcast(manager: MCBroadcast, didReceiveInvitationFromBroadcaster broadcaster: MCBroadcaster)
    func mcBroadcast(manager: MCBroadcast, didAcceptInvitationFromBroadcaster broadcaster: MCBroadcaster)
}

class MCBroadcast: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    /// The service type string.
    ///
    var serviceType = "my-service"
    
    /// The name that the peer will display during advertising.
    ///
    var displayName: String!
    
    /// The timeout in seconds that the browser will wait for invitation acceptance.
    ///
    var timeOut: Double!
    
    /// The delegate that will listen for broadcast callbacks.
    ///
    var delegate: MCBroadcastDelegate?
    
    private var peerId: MCPeerID!
    private var session: MCSession!
    private var browser: MCNearbyServiceBrowser!
    private var advertiser: MCNearbyServiceAdvertiser!
    private(set) var connectedPeers = [MCPeerID]()
    
    init(displayName: String, delegate: MCBroadcastDelegate?) {
        
        super.init()
        
        self.displayName = displayName
        self.timeOut = 20.0
        
        self.delegate = delegate
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let data = defaults.dataForKey("STORED_PEERID") {
            
            self.peerId = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? MCPeerID
        }
        else {
            
            self.peerId = MCPeerID(displayName: self.displayName)
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(self.peerId)
            
            defaults.setObject(data, forKey: "STORED_PEERID")
            defaults.synchronize()
        }
        
        self.session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .None)
        self.session.delegate = self;
        
        self.browser = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
        self.browser.delegate = self
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)
        self.advertiser.delegate = self;
    }
    
    //MARK: Public methods
    
    /// Starts browsing for nearby peers.
    ///
    func startBrownsing() {
        
        self.browser.startBrowsingForPeers()
    }
    
    /// Starts advertising peer.
    ///
    func startAdvertising() {
        
        self.advertiser.startAdvertisingPeer()
    }
    
    /// Stops browsing for nearby peers.
    ///
    func stopBrowsing() {
        
        self.browser.stopBrowsingForPeers()
    }
    
    /// Stops advertising peer.
    ///
    func stopAdvertising() {
        
        self.advertiser.stopAdvertisingPeer()
    }
    
    /// Sends multipeer connectivity object to connected peers.
    ///
    /// :param: object            The object to send.
    /// :param: toBroacasters     The peers that will receive the object. If nil then
    ///                           current session will send object to all connected peers.
    ///
    func sendObject(object: MCObject, toBroadcasters broadcasters: AnyObject?) {
        
        var toPeers = [AnyObject]()
        
        if let array: AnyObject = broadcasters {
            
            for broadcaster in array as! [MCBroadcaster] {
                toPeers.append(broadcaster.peerId)
            }
        }
        else {
            toPeers = self.session.connectedPeers
        }
        
        var error: NSError?
        
        var data = NSKeyedArchiver.archivedDataWithRootObject(object) as NSData
        
        if !self.session.sendData(data, toPeers: toPeers as [AnyObject], withMode: MCSessionSendDataMode.Reliable, error: &error) {
            
            if let theError = error {
                self.delegate?.mcBroadcast(self, didEncounterError: theError)
            }
        }
    }
    
    //MARK: MCNearbyServiceAdvertiser delegate
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        
        println("[DEBUG] \(__FUNCTION__) peer: \(peerID.displayName)")
        
        invitationHandler(true, self.session)
        
        let broadcaster = MCBroadcaster(peerID: peerID)
        
        self.delegate?.mcBroadcast(self, didReceiveInvitationFromBroadcaster: broadcaster)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        
        println("[DEBUG] \(__FUNCTION__) error: \(error.description)")
        
        self.delegate?.mcBroadcast(self, didEncounterError: error)
    }
    
    //MARK: MCNearbyServiceBrowser delegate
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        
        println("[DEBUG] \(__FUNCTION__) peer: \(peerID.displayName)")
        
        let broadcaster = MCBroadcaster(peerID: peerID)
        
        self.delegate?.mcBroadcast(self, foundBroadcaster: broadcaster)
        
        let shouldInvite: Bool = self.peerId.hash < peerID.hash
        
        if shouldInvite {
            
            println("[DEBUG] Inviting peer: \(peerID.displayName)")
            
            self.browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: self.timeOut)
        }
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        
        println("[DEBUG] \(__FUNCTION__) peer: \(peerID.displayName)")
        
        let broadcaster = MCBroadcaster(peerID: peerID)
        
        self.delegate?.mcBroadcast(self, lostBroadcaster: broadcaster)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        
        println("[DEBUG] \(__FUNCTION__) error: \(error.description)")
        
        self.delegate?.mcBroadcast(self, didEncounterError: error)
    }
    
    //MARK: MCSession delegate
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {

        switch state {
            
        case .NotConnected:
            
            println("[DEBUG] \(__FUNCTION__) state: Not connected to peer: \(peerID.displayName)")
            
            self.browser.startBrowsingForPeers()
            break
            
        case .Connecting:
            
            println("[DEBUG] \(__FUNCTION__) state: Connecting to peer: \(peerID.displayName)")
            break
            
        case .Connected:
            
            println("[DEBUG] \(__FUNCTION__) state: Connected to peer: \(peerID.displayName)")
            break
        }
        
        var broadcaster = MCBroadcaster(peerID: peerID)
        
        self.delegate?.mcBroadcast(self, broadcaster: broadcaster, didChangeState: MCBroadcastSessionState(rawValue: state.rawValue)!)
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
        let object = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! MCObject
        let broadcaster = MCBroadcaster(peerID: peerId)
        
        self.delegate?.mcBroadcast(self, didReceiveObject: object, fromBroadcaster: broadcaster)
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
    
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
}
