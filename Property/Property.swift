//
//  Property.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 12/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

typealias ChangeObserver = (PropertyType) -> Void

protocol PropertyType {
    func outputData() throws -> OutputData
    func outputDataDescription() throws -> OutputDataDescription
    func set(data: InputData) throws
    func onChange(observer: ChangeObserver)
}

class Property<TYPE>: PropertyType {
    
    var value: TYPE {
        didSet {
            tryToLog("set")
            observers.forEach { $0(self) }
        }
    }
    
    let writable: () -> Bool
    let loggingLabel: String?
    
    private var observers = [ChangeObserver]()
    
    init(_ value: TYPE,@autoclosure(escaping) writable: () -> Bool, loggingLabel:String? = nil) {
        
        observers = []
        self.value = value
        self.writable = writable
        self.loggingLabel = loggingLabel
        
        tryToLog("init")
    }
    
    func onChange(observer: ChangeObserver) {
        observers.append(observer)
    }
    
    func outputData() throws -> OutputData {
        tryToLog("outputData")
        return try OutputData(value)
    }
    
    func outputDataDescription() throws -> OutputDataDescription {
        tryToLog("outputDataDescription")
        return try OutputDataDescription(value, writable: writable())
    }
    
    func set (data: InputData) throws {
        guard writable() else {throw AudioUnitError.PropertyNotWritable}
        guard UInt32(sizeof(TYPE)) == data.size else {throw AudioUnitError.InvalidPropertySize}
        
        self.value = UnsafePointer<TYPE>(data.ptr).memory
    }
    
    func tryToLog(actionName: String) {
        guard let loggingLabel = loggingLabel else {return}
        
        Log.debug("\(loggingLabel): \(actionName) --> \(value)")
    }
}