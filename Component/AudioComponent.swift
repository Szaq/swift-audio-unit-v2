//
//  AudioComponent.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 09/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

protocol AudioComponent {
    init(_ instance: AudioComponentInstance) throws

    func initialize() throws
    func uninitialize() throws
    func getPropertyInfo(id: QualifiedPropertyID) throws -> OutputDataDescription
    func getProperty(id: QualifiedPropertyID) throws -> OutputData
    func setProperty(id: QualifiedPropertyID, data: InputData) throws

    mutating func addPropertyListener(id: AudioUnitPropertyID, _ listener: AudioUnitPropertyListenerProc, _ userData: UnsafeMutablePointer<Void>) throws
    mutating func removePropertyListener(id: AudioUnitPropertyID, _ listener: AudioUnitPropertyListenerProc) throws
    mutating func removePropertyListenerWithUserData(id: AudioUnitPropertyID, _ listener: AudioUnitPropertyListenerProc, _ userData: UnsafeMutablePointer<Void>) throws

    func process(inout actionFlags: AudioUnitRenderActionFlags,
                       timeStamp: AudioTimeStamp,
                       numberFrames: UInt32,
                       inout data: AudioBufferList) throws

    func render(inout actionFlags: AudioUnitRenderActionFlags,
                      timeStamp: AudioTimeStamp,
                      outputBusNumber: UInt32,
                      framesCount: UInt32,
                      inout data: UnsafeMutableAudioBufferListPointer) throws

    mutating func addRenderObserver(observer: RenderObserver) throws
    mutating func removeRenderObserver(observer: RenderObserver) throws

    func reset(scope: AudioUnitScope, element: AudioUnitElement) throws
}