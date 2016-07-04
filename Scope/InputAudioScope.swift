//
//  InputAudioScope.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 12/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

class InputAudioScope: AudioScope {
    override init<ElementType: AudioElement>(id: AudioUnitScope, parent: AudioUnitBase, elementType:ElementType.Type, numElements: UInt32) throws {
        try super.init(id: id, parent: parent, elementType: elementType, numElements: numElements)
    }

    override func setExtraProperty(id: QualifiedPropertyID, data: InputData) throws {
        if id.propertyID == kAudioUnitProperty_MakeConnection {
            guard Int(data.size) == sizeof(AudioUnitConnection) else {throw AudioUnitError.InvalidPropertySize}
            let connection = UnsafePointer<AudioUnitConnection>(data.ptr).memory
            guard let input = elements[Int(connection.destInputNumber)] as? InputAudioElement else {throw AudioUnitError.InvalidElement}

            if connection.sourceAudioUnit != nil {

                var streamDesc = AudioStreamBasicDescription()
                var size = UInt32(sizeof(AudioStreamBasicDescription))
                let err = AudioUnitGetProperty(
                    connection.sourceAudioUnit,
                    kAudioUnitProperty_StreamFormat,
                    kAudioUnitScope_Output,
                    connection.sourceOutputNumber,
                    &streamDesc,
                    &size)
                guard err == noErr else {
                    Log.debug("Failed to get connection source format")
                    throw AudioUnitError.NoConnection
                }
                input.streamFormat.value = StreamBasicDescription(streamDesc: streamDesc)
            }

            input.setConnection(connection)
            parent.notifyPropertyChanged(
                QualifiedPropertyID(
                    propertyID: id.propertyID,
                    scopeID: kAudioUnitScope_Input,
                    elementID: connection.destInputNumber,
                    audioUnit: parent.instance))
        } else {
            try super.setExtraProperty(id, data: data)
        }

    }
}