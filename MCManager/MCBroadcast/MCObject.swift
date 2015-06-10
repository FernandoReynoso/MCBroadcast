//
//  MCObject.swift
//  MCManager
//
//  Created by Fernando Reynoso on 6/8/15.
//  Copyright (c) 2015 Fernando Reynoso. All rights reserved.
//

import UIKit

class MCObject: NSObject, NSCoding {

    private var proxy = NSMutableDictionary()
    
    override init() {
        
        super.init()
    }
    
    var objectId: NSString? {
        
        get {
            return proxy["objectId"] as? NSString
        }
        
        set {
            proxy["objectId"] = newValue
        }
    }
    
    var flag: NSNumber? {
        
        get {
            return proxy["flag"] as? NSNumber
        }
        
        set {
            proxy["flag"] = newValue
        }
    }
    
    var text: NSString? {
        
        get {
            return proxy["text"] as? NSString
        }
        
        set {
            proxy["text"] = newValue
        }
    }
    
    var count: Int {
        
        get {
            return proxy.count
        }
    }
    
    func setObject(anObject: AnyObject, forKey aKey: NSCopying) {
        
        proxy.setObject(anObject, forKey: aKey)
    }
    
    func objectForKey(aKey: AnyObject) -> AnyObject? {
        
        return proxy.objectForKey(aKey)
    }
    
    func removeObjectForKey(aKey: AnyObject) {
        
        proxy.removeObjectForKey(aKey)
    }
    
    func keyEnumerator() -> NSEnumerator {
        
        return proxy.keyEnumerator()
    }
    
    func log() -> String {
        
        return self.proxy.description
    }
    
    //MARK: NSCoding protocol
    
    required init(coder aDecoder: NSCoder) {
        
        self.proxy = aDecoder.decodeObjectForKey("proxy") as! NSMutableDictionary
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(self.proxy,    forKey: "proxy")
    }
}
