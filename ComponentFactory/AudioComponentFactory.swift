//
//  AudioUnitsManager.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 06/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation
import AudioUnit

protocol AudioComponentFactory {

    func open(instance: AudioComponentInstance) throws
    func close() throws
    func initialize() throws
    func uninitialize() throws

    func getPropertyInfo(inID: QualifiedPropertyID, _ outDataSize: UnsafeMutablePointer<UInt32>, _ outWritable: UnsafeMutablePointer<DarwinBoolean>) throws
    func getProperty(inID: QualifiedPropertyID, _ outData: UnsafeMutablePointer<Void>, _ ioDataSize: UnsafeMutablePointer<UInt32>) throws
    func setProperty (inID: QualifiedPropertyID, _ inData: UnsafePointer<Void>, _ inDataSize: UInt32) throws


    func addPropertyListener(inID: AudioUnitPropertyID, _ inListener: AudioUnitPropertyListenerProc, _ inUserData: UnsafeMutablePointer<Void>) throws
    func removePropertyListener(inID: AudioUnitPropertyID, _ inListener: AudioUnitPropertyListenerProc) throws
    func removePropertyListenerWithUserData(inID: AudioUnitPropertyID, _ inListener: AudioUnitPropertyListenerProc, _ inUserData: UnsafeMutablePointer<Void>) throws
    func addRenderNotify(inCallback: AURenderCallback, _ inUserData: UnsafeMutablePointer<Void>) throws
    func removeRenderNotify(inCallback: AURenderCallback, _ inUserData: UnsafeMutablePointer<Void>) throws

    func render(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                inTimeStamp: UnsafePointer<AudioTimeStamp>,
                inOutputBusNumber: UInt32,
                inNumberFrames: UInt32,
                ioData: UnsafeMutablePointer<AudioBufferList>) throws

    func process(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                 inTimeStamp: UnsafePointer<AudioTimeStamp>,
                 inNumberFrames: UInt32,
                 ioData: UnsafeMutablePointer<AudioBufferList>) throws

    func reset(inScope: AudioUnitScope, inElement: AudioUnitElement) throws
}

class GenericAudioComponentFactory<EffectType: AudioComponent>: AudioComponentFactory {
    var component: EffectType?

    func open(instance: AudioComponentInstance) throws {
        Log.debug("Open")
        component = try EffectType(instance)
    }

    func close() throws {
        Log.debug("Close")
        component = nil
    }

    func initialize() throws {
        try component?.initialize()
    }

    func uninitialize() throws {
        try component?.uninitialize()
    }

    func getPropertyInfo(inID: QualifiedPropertyID, _ outDataSize: UnsafeMutablePointer<UInt32>, _ outWritable: UnsafeMutablePointer<DarwinBoolean>) throws {

        Log.debug("getPropertyInfo(\(inID)) --> ")

        guard let component = component else {throw AudioUnitError.Uninitialized}

        let info = try component.getPropertyInfo(inID)
        Log.debug("size: \(info.size), writable: \(info.writable)")

        try info.copyTo(outDataSize, outWritable)
    }

    func getProperty(inID: QualifiedPropertyID, _ outData: UnsafeMutablePointer<Void>, _ ioDataSize: UnsafeMutablePointer<UInt32>) throws {

        Log.debug("getProperty(\(inID)) ->")

        guard let component = component else {throw AudioUnitError.Uninitialized}

        let data = try component.getProperty(inID)

        try data.copyTo(outData, ioDataSize)
    }

    func setProperty(inID: QualifiedPropertyID, _ inData: UnsafePointer<Void>, _ inDataSize: UInt32) throws {
        Log.debug("setProperty(\(inID)) -> size: \(inDataSize)")

        guard let component = component else {throw AudioUnitError.Uninitialized}


        try component.setProperty(inID, data: InputData(inData, inDataSize))
    }

    func addPropertyListener(inID: AudioUnitPropertyID, _ inListener: AudioUnitPropertyListenerProc, _ inUserData: UnsafeMutablePointer<Void>) throws {
        Log.debug("addPropertyListener(\(inID))")

        guard var component = component else {throw AudioUnitError.Uninitialized}
        try component.addPropertyListener(inID, inListener, inUserData)
    }

    func removePropertyListener(inID: AudioUnitPropertyID, _ inListener: AudioUnitPropertyListenerProc) throws {
        Log.debug("removePropertyListener(\(inID))")

        guard var component = component else {throw AudioUnitError.Uninitialized}
        try component.removePropertyListener(inID, inListener)
    }

    func removePropertyListenerWithUserData(inID: AudioUnitPropertyID, _ inListener: AudioUnitPropertyListenerProc, _ inUserData: UnsafeMutablePointer<Void>) throws {
        Log.debug("removePropertyListenerWithUserData(\(inID))")

        guard var component = component else {throw AudioUnitError.Uninitialized}
        try component.removePropertyListenerWithUserData(inID, inListener, inUserData)
    }

    func render(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                inTimeStamp: UnsafePointer<AudioTimeStamp>,
                inOutputBusNumber: UInt32,
                inNumberFrames: UInt32,
                ioData: UnsafeMutablePointer<AudioBufferList>) throws {

        //Log.debug("Render --> timestamp: \(inTimeStamp.memory.mSampleTime) | actionFlags:\(ioActionFlags.memory)")

        guard let component = component else {throw AudioUnitError.Uninitialized}

        guard ioActionFlags != nil && inTimeStamp != nil && ioData != nil else {throw AudioUnitError.InvalidParameter}

        var actionFlags = ioActionFlags.memory
        var source = UnsafeMutableAudioBufferListPointer(ioData)

        try component.render(&actionFlags,
                    timeStamp: inTimeStamp.memory,
                    outputBusNumber: inOutputBusNumber,
                    framesCount: inNumberFrames,
                    data: &source)

        ioActionFlags.initialize(actionFlags)

        let dest = UnsafeMutableAudioBufferListPointer(ioData)

        if dest.count > 0 && dest[0].mData != nil {
            for (var destBuffer, sourceBuffer) in zip(dest, source) {
                try sourceBuffer.copy(to: &destBuffer)
            }
        } else {
            for index in 0..<min(dest.count, source.count) {
                dest[index] = source[index];
            }
            dest.count = source.count
        }
    }

    func process(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                inTimeStamp: UnsafePointer<AudioTimeStamp>,
                inNumberFrames: UInt32,
                ioData: UnsafeMutablePointer<AudioBufferList>) throws {

        Log.debug("process --->")

        guard let component = component else {throw AudioUnitError.Uninitialized}

        guard ioActionFlags != nil && inTimeStamp != nil && ioData != nil else {throw AudioUnitError.InvalidParameter}

        var actionFlags = ioActionFlags.memory
        var data = ioData.memory

        try component.process(&actionFlags,
                             timeStamp: inTimeStamp.memory,
                             numberFrames: inNumberFrames,
                             data: &data)

        ioActionFlags.initialize(actionFlags)
        ioData.initialize(data)
    }

    func addRenderNotify(inCallback: AURenderCallback, _ inUserData: UnsafeMutablePointer<Void>) throws {
        Log.debug("addRenderNotify")

        guard var component = component else {throw AudioUnitError.Uninitialized}
        try component.addRenderObserver(RenderObserver(callback: inCallback, userData: inUserData))
    }

    func removeRenderNotify(inCallback: AURenderCallback, _ inUserData: UnsafeMutablePointer<Void>) throws {
        Log.debug("removeRenderNotify")

        guard var component = component else {throw AudioUnitError.Uninitialized}
        try component.removeRenderObserver(RenderObserver(callback: inCallback, userData: inUserData))
    }

    func reset(inScope: AudioUnitScope, inElement: AudioUnitElement) throws {
        Log.debug("reset --->")

        guard let component = component else {throw AudioUnitError.Uninitialized}
        try component.reset(inScope, element: inElement)
    }
}