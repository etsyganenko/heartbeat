//
//  GNKObservableObject.swift
//  Genek
//
//  Created by Genek on 2/23/16.
//  Copyright © 2016 IDAP. All rights reserved.
//

import UIKit

typealias GNKNotificationHandler = () -> ()

class GNKObservableObject: NSObject {
    
    // MARK: - Accessors
    
    var state: UInt {
        willSet(newValue) {
            self.notifyOfStateChange(newValue)
        }
    }
    
    var handlersDictionary: Dictionary<UInt, GNKNotificationHandler>!
    
    var observersHashTable: NSHashTable?
    
    // MARK: - Initialization
    
    override init() {
        self.state = 0
        self.observersHashTable = NSHashTable.weakObjectsHashTable()
        self.handlersDictionary = Dictionary()
        
        super.init()
    }
    
    // MARK: - Public
    
    func addObserver(observer: AnyObject) {
        self.observersHashTable!.addObject(observer)
    }
    
    func removeObserver(observer: AnyObject) {
        self.observersHashTable!.removeObject(observer)
    }
    
    func notifyOfStateChange(state: UInt) {
        self.notifyOfStateChangeWithHandler(self.handlerForState(state)!)
    }
    
    func addHandler(handler: GNKNotificationHandler, state: UInt) {
        self.handlersDictionary![state] = handler
    }
    
    func removeHandler(handler: GNKNotificationHandler, state: UInt) {
        self.handlersDictionary!.removeValueForKey(state)
    }
    
    // MARK: - Private
    
    private func handlerForState(state: UInt) -> GNKNotificationHandler? {
        return self.handlersDictionary![state]
    }
    
    private func notifyOfStateChangeWithHandler(handler: GNKNotificationHandler) {
        handler()
    }
}

