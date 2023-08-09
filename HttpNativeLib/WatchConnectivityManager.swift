//
//  WatchConnectivityManager.swift
//  HttpNativeLib
//
//  Created by Vinícius Gonçalves de Andrade on 07/08/23.
//  Copyright © 2023 Dougly. All rights reserved.
//

import WatchConnectivity

public class WatchConnectivityManager: NSObject, WCSessionDelegate {
    
    public static let shared = WatchConnectivityManager()
    
    public override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion here
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive here
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation here
    }
    
    // Other WCSessionDelegate methods
    
    // Function to check paired devices
    public func checkPairedDevices() -> [String: Any] {
        var resultDictionary: [String: Any] = [:]
        
        if WCSession.isSupported() {
            let session = WCSession.default
            
            if session.activationState == .activated && session.isPaired {
                resultDictionary["isWatchPaired"] = true
            } else {
                resultDictionary["isWatchPaired"] = false
            }
        } else {
            resultDictionary["isWatchPaired"] = false
        }
        
        return resultDictionary
    }
}
