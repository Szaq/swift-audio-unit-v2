//
//  ConvertingProperty.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 12/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation


protocol PropertyValueConverter {
    associatedtype PropertyType
    associatedtype UnderlyingType
    func get(value: PropertyType) -> UnderlyingType
    func set(value: UnderlyingType) -> PropertyType
}

struct DefaultConverter<TYPE>: PropertyValueConverter {
    func get(value: TYPE) -> TYPE {
        return value
    }

    func set(value: TYPE) -> TYPE {
        return value
    }
}

struct BoolUInt32Converter: PropertyValueConverter {
    func get(value: Bool) -> UInt32 {
        return value ? 1 : 0
    }

    func set(value: UInt32) -> Bool {
        return value == 1
    }
}

struct BasicAudioStreamConverter: PropertyValueConverter {
    func get(value: StreamBasicDescription) -> AudioStreamBasicDescription {
        return value.audioStreamBasicDescription
    }
    func set(value: AudioStreamBasicDescription) -> StreamBasicDescription {
        return StreamBasicDescription(streamDesc: value)
    }
}

class ConvertingProperty<CONVERTER where CONVERTER: PropertyValueConverter>: Property<CONVERTER.PropertyType> {
    let converter: CONVERTER

    init(_ value: CONVERTER.PropertyType, writable: Bool, converter: CONVERTER, loggingLabel:String? = nil) {
        self.converter = converter
        super.init(value, writable: writable, loggingLabel: loggingLabel)
    }

    override func outputData() throws -> OutputData {
        return try OutputData(converter.get(value))
    }

    override func outputDataDescription() throws -> OutputDataDescription {
        return try OutputDataDescription(converter.get(value), writable: writable())
    }

    override func set(data: InputData) throws {
        guard writable() else {throw AudioUnitError.PropertyNotWritable}
        guard UInt32(sizeof(CONVERTER.UnderlyingType.self)) <= data.size else {throw AudioUnitError.InvalidPropertySize}

        self.value = converter.set(UnsafePointer<CONVERTER.UnderlyingType>(data.ptr).memory)
    }

}