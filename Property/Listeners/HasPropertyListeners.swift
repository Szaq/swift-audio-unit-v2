//
//  HasPropertyListeners.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 13/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

struct PropertyListener {
    let listener: AudioUnitPropertyListenerProc
    let userData: UnsafeMutablePointer<Void>
}

protocol HasPropertyListeners {

    var propertyListeners: [AudioUnitPropertyID: [PropertyListener]] {get set}

    mutating func addPropertyListener(id: AudioUnitPropertyID, _ listener: AudioUnitPropertyListenerProc, _ userData: UnsafeMutablePointer<Void>) throws
    mutating func removePropertyListener(id: AudioUnitPropertyID, _ listener: AudioUnitPropertyListenerProc) throws
    mutating func removePropertyListenerWithUserData(id: AudioUnitPropertyID, _ listener: AudioUnitPropertyListenerProc, _ userData: UnsafeMutablePointer<Void>) throws

    func notifyPropertyChanged(propertyID: QualifiedPropertyID) throws
}

extension HasPropertyListeners {
    mutating func addPropertyListener(id: AudioUnitPropertyID, _ listener: AudioUnitPropertyListenerProc, _ userData: UnsafeMutablePointer<Void>) throws {
        var specificListeners = propertyListeners[id] ?? []
        specificListeners.append(PropertyListener(listener: listener, userData: userData))
        propertyListeners[id] = specificListeners
    }

    mutating func removePropertyListener(id: AudioUnitPropertyID, _ listener: AudioUnitPropertyListenerProc) throws {
        guard var specificListeners = propertyListeners[id] else {throw AudioUnitError.InvalidProperty}
        for (index, enumeratedListener) in specificListeners.enumerate() {
            if CheckListenersAreEqual(enumeratedListener.listener, listener) {
                specificListeners.removeAtIndex(index)
                propertyListeners[id] = specificListeners
                return
            }
        }
    }

    mutating func removePropertyListenerWithUserData(id: AudioUnitPropertyID, _ listener: AudioUnitPropertyListenerProc, _ userData: UnsafeMutablePointer<Void>) throws {
        guard var specificListeners = propertyListeners[id] else {throw AudioUnitError.InvalidProperty}
        for (index, enumeratedListener) in specificListeners.enumerate() {
            if CheckListenersAreEqual(enumeratedListener.listener, listener) && enumeratedListener.userData == userData {
                specificListeners.removeAtIndex(index)
                propertyListeners[id] = specificListeners
                return
            }
        }
    }

    func notifyPropertyChanged(property: QualifiedPropertyID) {
        Log.debug("Notifying about property change: \(property)")
        guard let listeners = propertyListeners[property.propertyID],
        audioUnit = property.audioUnit
            else {
                return
        }

        Log.debug("Listeners: \(listeners.count)")
        for listener in listeners {
            listener.listener(listener.userData, audioUnit, property.propertyID, property.scopeID, property.elementID)
        }
    }
}