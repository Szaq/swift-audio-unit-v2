//
//  NilableProperty.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 18/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

class NilableProperty<TYPE>: Property<TYPE?> {
    
    init(_ value: TYPE?, writable: Bool, loggingLabel:String? = nil) {
        super.init(value, writable: writable, loggingLabel: loggingLabel)
    }
    
    override func outputData() throws -> OutputData {
        if let value = value {
            return try OutputData(value)
        } else {
            return OutputData(data: nil, size: UInt32(sizeof(TYPE)))
        }
    }
    
    override func outputDataDescription() throws -> OutputDataDescription {
        return try OutputDataDescription(value, writable: writable())
    }
    
    override func set(data: InputData) throws {
        guard writable() else {throw AudioUnitError.PropertyNotWritable}
        guard UInt32(sizeof(TYPE)) == data.size else { throw AudioUnitError.InvalidPropertySize}
        if data.ptr != nil {
            self.value = UnsafePointer<TYPE>(data.ptr).memory
        } else {
            self.value = nil
        }
    }
}