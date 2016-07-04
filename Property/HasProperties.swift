//
//  HasProperties.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 12/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

/**
 *  Protocol declared by objects which can be queried for Audio Unit Properties.
 */
protocol HasProperties {
    /**
     Get list of properties implemented by this object.

     - returns: Dictionary mapping property IDs to to property objects.
     
     - remark: This function must be implemented.
     */
    func properties() -> [AudioUnitPropertyID: PropertyType]

    /**
     If this objects requires some custom handling of some properties, than it should implement
     this method in order to handle get requests.

     - parameter id: ID of property

     - throws: AudioUnitError

     - returns: Value of property
     */
    func getExtraProperty(id: QualifiedPropertyID) throws -> OutputData

    /**
     If this objects requires some custom handling of some properties, than it should implement
     this method in order to handle getInfo requests.

     - parameter id: ID of property.

     - throws: AudioUnitError

     - returns: Info about property
     */
    func getExtraPropertyInfo(id: QualifiedPropertyID) throws -> OutputDataDescription

    /**
     If this objects requires some custom handling of some properties, than it should implement
     this method in order to handle set requests.

     - parameter id: ID of property
     - parameter data: Value to set property to

     - throws: AudioUnitError
     */
    func setExtraProperty(id: QualifiedPropertyID, data: InputData) throws

    ///Implementation of `AudioComponent.getProperty`. Implemented by protocol extension.
    func getProperty(id: QualifiedPropertyID) throws -> OutputData
    ///Implementation of `AudioComponent.getPropertyInfo`. Implemented by protocol extension.
    func getPropertyInfo(id: QualifiedPropertyID) throws -> OutputDataDescription
    ///Implementation of `AudioComponent.setProperty`. Implemented by protocol extension.
    func setProperty(id: QualifiedPropertyID, data: InputData) throws
}

extension HasProperties {
    func getProperty(id: QualifiedPropertyID) throws -> OutputData {

        if let property = properties()[id.propertyID] {
            return try property.outputData()
        }

        return try getExtraProperty(id)
    }

    func getPropertyInfo(id: QualifiedPropertyID) throws -> OutputDataDescription {

        if let property = properties()[id.propertyID] {
            return try property.outputDataDescription()
        }

        return try getExtraPropertyInfo(id)
    }

    func setProperty(id: QualifiedPropertyID, data: InputData) throws {
        guard let property = properties()[id.propertyID] else {
            try setExtraProperty(id, data: data)
            return
        }

        try property.set(data)
    }

    func getExtraProperty(id: QualifiedPropertyID) throws -> OutputData {
        throw AudioUnitError.InvalidProperty
    }

    func getExtraPropertyInfo(id: QualifiedPropertyID) throws -> OutputDataDescription {
        throw AudioUnitError.InvalidProperty
    }

    func setExtraProperty(id: QualifiedPropertyID, data: InputData) throws {
        throw AudioUnitError.InvalidProperty
    }
}
