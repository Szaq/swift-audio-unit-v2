//
//  AudioElement.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 09/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

class AudioElement: HasProperties, ObservesPropertyChanges {
    let parent: AudioScope
    let id: AudioUnitElement
    let streamFormat: Property<StreamBasicDescription>
    private(set) var buffer = UnsafeMutableAudioBufferListPointer(nil)

    required init(_ id: AudioUnitElement, parent: AudioScope) throws {
        self.parent = parent
        self.id = id
        let format = try StreamBasicDescription(sampleRate: AudioDefaultSampleRate,
                                                numChannels: 2,
                                                pcmf: .Float32,
                                                interleaved: false)
        streamFormat = ConvertingProperty(format, writable:!parent.parent.initialized, converter: BasicAudioStreamConverter(), loggingLabel: "streamFormat")
        streamFormat.onChange {[weak self] _ in
            self?.allocateBuffer()
        }
        
        registerPropertyObservers()
    }

    func allocateBuffer(framesCount: UInt32? = nil) {
        buffer = UnsafeMutableAudioBufferListPointer.allocate(streamFormat.value, framesCount: framesCount ?? parent.parent.maxFramesPerSlice.value)
    }

    func deallocateBuffer() {
        buffer = UnsafeMutableAudioBufferListPointer(nil)
    }

    func properties() -> [AudioUnitPropertyID : PropertyType] {
        return [kAudioUnitProperty_StreamFormat: streamFormat]
    }
    
    func notifyPropertyChanged(id: AudioUnitPropertyID) {
        self.parent.parent.notifyPropertyChanged(
            QualifiedPropertyID(
                propertyID: id,
                scopeID: self.parent.id,
                elementID: self.id,
                audioUnit: self.parent.parent.instance))
    }
}