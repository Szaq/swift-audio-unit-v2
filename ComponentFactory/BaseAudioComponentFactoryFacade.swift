//
//  AudioComponentFactoryFacade.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 09/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation
import AudioUnit

func factory(ptr: UnsafeMutablePointer<Void>) throws -> AudioComponentFactory {
    guard let object = GetAudioComponentFactory(ptr) as? AudioComponentFactoryFacade else {
        Log.debug("factory(): Failed to get factory")
        throw AudioUnitError.InvalidElement
    }

    return  object.factory
}

func tryFactoryMethod(ptr: UnsafeMutablePointer<Void>, block: (AudioComponentFactory) throws -> Void) -> OSStatus {
    do {
        try block(try factory(ptr))
    } catch let error as AudioUnitError {
        Log.debug(" ---> \(error)")
        return error.rawValue

    } catch let error {
        Log.debug(" ---> \(error)")
        return AudioUnitError.UnknownError.rawValue
    }

    //Log.debug(" ---> OK")
    return noErr
}

func openComponent(ptr: UnsafeMutablePointer<Void>, instance: AudioComponentInstance) -> OSStatus {
    return tryFactoryMethod(ptr) { factory in
        try factory.open(instance)
    }
}

func closeComponent(ptr: UnsafeMutablePointer<Void>) -> OSStatus {
    return tryFactoryMethod(ptr) { factory in
        try factory.close()
    }
}

func initializeComponent(ptr: UnsafeMutablePointer<Void>) -> OSStatus {
    return tryFactoryMethod(ptr) { factory in
        try factory.initialize()
    }
}

func unnitializeComponent(ptr: UnsafeMutablePointer<Void>) -> OSStatus {
    return tryFactoryMethod(ptr) { factory in
        try factory.uninitialize()
    }
}

func getComponentPropertyInfo(inUnit: UnsafeMutablePointer<Void>, _ inID: AudioUnitPropertyID, _ inScope: AudioUnitScope, _ inElement: AudioUnitElement, _ outDataSize: UnsafeMutablePointer<UInt32>, _ outWritable: UnsafeMutablePointer<DarwinBoolean>) -> OSStatus {

    return tryFactoryMethod(inUnit) { factory in
        let id = QualifiedPropertyID(propertyID: inID, scopeID: inScope, elementID: inElement, audioUnit: nil)
        try factory.getPropertyInfo(id, outDataSize, outWritable)
    }
}

func getComponentProperty(inUnit: UnsafeMutablePointer<Void>, _ inID: AudioUnitPropertyID, _ inScope: AudioUnitScope, _ inElement: AudioUnitElement, _ outData: UnsafeMutablePointer<Void>, _ ioDataSize: UnsafeMutablePointer<UInt32>) -> OSStatus {

    return tryFactoryMethod(inUnit) { factory in
        let id = QualifiedPropertyID(propertyID: inID, scopeID: inScope, elementID: inElement, audioUnit: nil)
        try factory.getProperty(id, outData, ioDataSize)
    }
}

func setComponentProperty (inUnit: UnsafeMutablePointer<Void>, inID: AudioUnitPropertyID, inScope: AudioUnitScope, inElement: AudioUnitElement, inData: UnsafePointer<Void>, inDataSize: UInt32) -> OSStatus {
    return tryFactoryMethod(inUnit) { factory in
        let id = QualifiedPropertyID(propertyID: inID, scopeID: inScope, elementID: inElement, audioUnit: nil)
        try factory.setProperty(id, inData, inDataSize)
    }
}

func addComponentPropertyListener(inUnit: UnsafeMutablePointer<Void>, inID: AudioUnitPropertyID, inListener: AudioUnitPropertyListenerProc, inUserData: UnsafeMutablePointer<Void>) -> OSStatus {

    return tryFactoryMethod(inUnit) { factory in
        try factory.addPropertyListener(inID, inListener, inUserData)
    }
}

func removeComponentPropertyListener(inUnit: UnsafeMutablePointer<Void>, inID: AudioUnitPropertyID, inListener: AudioUnitPropertyListenerProc) -> OSStatus {

    return tryFactoryMethod(inUnit) { factory in
        try factory.removePropertyListener(inID, inListener)
    }
}
func removeComponentPropertyListenerWithUserData(inUnit: UnsafeMutablePointer<Void>, inID: AudioUnitPropertyID, inListener: AudioUnitPropertyListenerProc, inUserData: UnsafeMutablePointer<Void>) -> OSStatus {

    return tryFactoryMethod(inUnit) { factory in
        try factory.removePropertyListenerWithUserData(inID, inListener, inUserData)
    }
}

func getComponentParameter (inUnit: UnsafeMutablePointer<Void>, inID: AudioUnitParameterID, inScope: AudioUnitScope, inElement: AudioUnitElement, outValue: UnsafeMutablePointer<AudioUnitParameterValue>) -> OSStatus {
    Log.debug("getComponentParameter:\(inID)")
    return noErr;
}

func setComponentParameter(inUnit: UnsafeMutablePointer<Void>, inID: AudioUnitParameterID, inScope: AudioUnitScope, inElement: AudioUnitElement, inValue: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32) -> OSStatus {
    Log.debug("setComponentParameter:\(inID)")
return noErr;
}

func scheduleParameters(inUnit: UnsafeMutablePointer<Void>, inEvents: UnsafePointer<AudioUnitParameterEvent>, inNumEvents: UInt32) -> OSStatus {
    Log.debug("scheduleParameters:\(inNumEvents)")
return noErr;
}


func renderComponent(inComponentStorage: UnsafeMutablePointer<Void>,
                     ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                     inTimeStamp: UnsafePointer<AudioTimeStamp>,
                     inOutputBusNumber: UInt32,
                     inNumberFrames: UInt32,
                     ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
    let response = tryFactoryMethod(inComponentStorage) { factory in
        try factory.render(ioActionFlags, inTimeStamp: inTimeStamp, inOutputBusNumber: inOutputBusNumber, inNumberFrames: inNumberFrames, ioData: ioData)
    }

    /*let descriptionsFloat32 = UnsafeMutableAudioBufferListPointer(ioData).map {"\($0.mDataByteSize)| \($0.dumpFirst(Float32.self, count: 10))"}.joinWithSeparator("\n")
    let descriptionsFloat64 = UnsafeMutableAudioBufferListPointer(ioData).map {"\($0.mDataByteSize)| \($0.dumpFirst(Float64.self, count: 10))"}.joinWithSeparator("\n")
    let descriptionsInt16 = UnsafeMutableAudioBufferListPointer(ioData).map {"\($0.mDataByteSize)| \($0.dumpFirst(Int16.self, count: 10))"}.joinWithSeparator("\n")
    let descriptionsUInt16 = UnsafeMutableAudioBufferListPointer(ioData).map {"\($0.mDataByteSize)| \($0.dumpFirst(UInt16.self, count: 10))"}.joinWithSeparator("\n")
    let descriptionsInt32 = UnsafeMutableAudioBufferListPointer(ioData).map {"\($0.mDataByteSize)| \($0.dumpFirst(Int32.self, count: 10))"}.joinWithSeparator("\n")
    let descriptionsUInt32 = UnsafeMutableAudioBufferListPointer(ioData).map {"\($0.mDataByteSize)| \($0.dumpFirst(UInt32.self, count: 10))"}.joinWithSeparator("\n")
    let descriptionsInt64 = UnsafeMutableAudioBufferListPointer(ioData).map {"\($0.mDataByteSize)| \($0.dumpFirst(Int64.self, count: 10))"}.joinWithSeparator("\n")
    let descriptionsUInt64 = UnsafeMutableAudioBufferListPointer(ioData).map {"\($0.mDataByteSize)| \($0.dumpFirst(UInt64.self, count: 10))"}.joinWithSeparator("\n")
    Log.debug("Render finished:\n - Float32:\n \(descriptionsFloat32)\n" +
        " - Float64:\n \(descriptionsFloat64)\n" +
        " - Int16:\n \(descriptionsInt16)\n" +
        " - UInt16:\n \(descriptionsUInt16)\n" +
        " - Int32:\n \(descriptionsInt32)\n" +
        " - UInt32:\n \(descriptionsUInt32)\n" +
        " - Int64:\n \(descriptionsInt64)\n" +
        " - UInt64:\n \(descriptionsUInt64)\n")
*/
    return response
}

func renderComponentComplex(inUnit: UnsafeMutablePointer<Void>, ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimeStamp: UnsafePointer<AudioTimeStamp>, inOutputBusNumber: UInt32, inNumberOfPackets: UInt32, outNumberOfPackets: UnsafeMutablePointer<UInt32>, outPacketDescriptions: UnsafeMutablePointer<AudioStreamPacketDescription>, ioData: UnsafeMutablePointer<AudioBufferList>, outMetadata: UnsafeMutablePointer<Void>, outMetadataByteSize: UnsafeMutablePointer<UInt32>) -> OSStatus {
    Log.debug("renderComponentComplex")
return noErr;
}

func addComponentRenderNotify(inUnit: UnsafeMutablePointer<Void>, inCallback: AURenderCallback, inUserData: UnsafeMutablePointer<Void>) -> OSStatus {
    return tryFactoryMethod(inUnit) { factory in
        try factory.addRenderNotify(inCallback, inUserData)
    }
}

func removeComponentRenderNotify(inUnit: UnsafeMutablePointer<Void>, inCallback: AURenderCallback, inUserData: UnsafeMutablePointer<Void>) -> OSStatus {
    return tryFactoryMethod(inUnit) { factory in
        try factory.removeRenderNotify(inCallback, inUserData)
    }
}

func processComponent(inComponentStorage: UnsafeMutablePointer<Void>,
                      ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                      inTimeStamp: UnsafePointer<AudioTimeStamp>,
                      inNumberFrames: UInt32,
                      ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
    print("processComponent")
    return tryFactoryMethod(inComponentStorage) { factory in
        try factory.process(ioActionFlags, inTimeStamp: inTimeStamp, inNumberFrames: inNumberFrames, ioData: ioData)
    }
}

func processComponentMultiple(inUnit: UnsafeMutablePointer<Void>, ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimeStamp: UnsafePointer<AudioTimeStamp>, inNumberFrames: UInt32, inNumberInputBufferLists: UInt32, inInputBufferLists: UnsafeMutablePointer<UnsafePointer<AudioBufferList>>, inNumberOutputBufferLists: UInt32, ioOutputBufferLists: UnsafeMutablePointer<UnsafeMutablePointer<AudioBufferList>>) -> OSStatus {
    Log.debug("processComponentMultiple")
    return noErr;
}

func resetComponent(inComponentStorage: UnsafeMutablePointer<Void>,inScope: AudioUnitScope, inElement: AudioUnitElement) -> OSStatus {
    return tryFactoryMethod(inComponentStorage) { factory in
        try factory.reset(inScope, inElement: inElement)
    }
}


@objc class BaseAudioComponentFactoryFacade: NSObject {

    let factory: AudioComponentFactory
    init(_ factory: AudioComponentFactory) {
        self.factory = factory
    }


    func interface() -> AudioComponentPlugInInterface {
        return AudioComponentPlugInInterface(Open: openComponent,
                                             Close: closeComponent,
                                             Lookup: { selector in
                                                let functions = AudioUnitFunctions(
                                                    initialize: initializeComponent,
                                                    uninitialize: unnitializeComponent,
                                                    getPropertyInfo: getComponentPropertyInfo,
                                                    getProperty: getComponentProperty,
                                                    setProperty: setComponentProperty,
                                                    addPropertyListener: addComponentPropertyListener,
                                                    removePropertyListener: removeComponentPropertyListener,
                                                    removePropertyListenerWithUserData: removeComponentPropertyListenerWithUserData,
                                                    getParameter: getComponentParameter,
                                                    setParameter: setComponentParameter,
                                                    scheduleParameters: scheduleParameters,
                                                    process: processComponent,
                                                    processMutltiple: processComponentMultiple,
                                                    render: renderComponent,
                                                    complexRender: renderComponentComplex,
                                                    addRenderNotify: addComponentRenderNotify,
                                                    removeRenderNotify: removeComponentRenderNotify,
                                                    reset: resetComponent)

                                                return Lookup(selector, functions)
            },
                                             reserved: nil)
    }
    
}
