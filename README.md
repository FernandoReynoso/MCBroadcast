MCBroadcast is a simple way to communicate with nearby devices using Multipeer Connectivity framework.

How it works
------------

 1. Browse and advertise service
 2. Find nearby peers to invite to session or get invited automatically

Usage
----
----------
**Initialization**

`let manager = MCBroadcast(displayName: String, delegate: MCBroadcastDelegate?)`


**Browsing nearby peers**

 `func startBrowsing()`
 

**Advertising service**

`func startAdversiting()`


**Sending data to connected peers**

`func sendObject(object: MCObject, toBroadcasters: broadcasters: AnyObject?)`


**More...**

**Stop browsing**

`func stopBrowsing()`


**Stop Advertise**

`func stopAdvertise()`


Properties
----------
----------
`var serviceType: String`

The service type string.


`var displayName: String`

The name that the peer will display during advertising.


`var timeOut: Double`

The timeout in seconds that the browser will wait for invitation acceptance.


`var delegate: MCBroadcastDelegate?`

The delegate that will listen for broadcast callbacks.


Delegate
--------

----------
`func mcBroadcast(manager: MCBroadcast, didReceiveObject object: MCObject?, fromBroadcaster broadcaster: MCBroadcaster)`

`func mcBroadcast(manager: MCBroadcast, didEncounterError error: NSError)`

`func mcBroadcast(manager: MCBroadcast, foundBroadcaster broadcaster: MCBroadcaster)`

`func mcBroadcast(manager: MCBroadcast, lostBroadcaster broadcaster: MCBroadcaster)`

`func mcBroadcast(manager: MCBroadcast, broadcaster: MCBroadcaster, didChangeState state: MCBroadcastSessionState)`

`func mcBroadcast(manager: MCBroadcast, didReceiveInvitationFromBroadcaster broadcaster: MCBroadcaster)`

`func mcBroadcast(manager: MCBroadcast, didAcceptInvitationFromBroadcaster broadcaster: MCBroadcaster)`


Pull request welcome!
---------------------
