//
//  HasRenderObservers.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 13/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

struct RenderObserver {
    let callback: AURenderCallback
    let userData: UnsafeMutablePointer<Void>
}

protocol HasRenderObservers {
    var observers: [RenderObserver] {get set}

    mutating func addRenderObserver(observer: RenderObserver) throws
    mutating func removeRenderObserver(observer: RenderObserver) throws

    func notifyRender(actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                      timeStamp: UnsafePointer<AudioTimeStamp>,
                      busNumber: UInt32,
                      framesCount: UInt32,
                      data: UnsafeMutableAudioBufferListPointer)
}

extension HasRenderObservers {

    mutating func addRenderObserver(observer: RenderObserver) throws {
        observers.append(observer)
    }

    mutating func removeRenderObserver(observer: RenderObserver) throws {
        for (index, enumeratedObserver) in observers.enumerate() {
            if CheckRenderCallbacksAreEqual(observer.callback, enumeratedObserver.callback) &&
                observer.userData == enumeratedObserver.userData {
                observers.removeAtIndex(index)
            }
        }
    }
/*

     @param			inRefCon
					The client data that is provided either with the AURenderCallbackStruct or as
					specified with the Add API call
     @param			ioActionFlags
					Flags used to describe more about the context of this call (pre or post in the
					notify case for instance)
     @param			inTimeStamp
					The times stamp associated with this call of audio unit render
     @param			inBusNumber
					The bus number associated with this call of audio unit render
     @param			inNumberFrames
					The number of sample frames that will be represented in the audio data in the
					provided ioData parameter
     @param			ioData

     */
    func notifyRender(actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                      timeStamp: UnsafePointer<AudioTimeStamp>,
                      busNumber: UInt32,
                      framesCount: UInt32,
                      data: UnsafeMutableAudioBufferListPointer) {
        observers.forEach { observer in
            observer.callback(observer.userData, actionFlags, timeStamp, busNumber, framesCount, data.unsafeMutablePointer)
        }
    }

}