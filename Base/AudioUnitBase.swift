//
//  AudioUnitBase.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 06/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation
import AudioUnit

let AudioDefaultSampleRate = 44100.0
let AudioDefaultMaxFramesPerSlice: UInt32 = 1156

class AudioUnitBase: HasProperties, HasPropertyListeners, ObservesPropertyChanges, HasRenderObservers {

    let instance: AudioComponentInstance
    private let initParams: AudioUnitBaseInitParams

    var inputs: AudioScope?
    var outputs: AudioScope?

    var propertyListeners = [AudioUnitPropertyID : [PropertyListener]]()
    var observers = [RenderObserver]()


    private var buffersAllocated = false
    private var elementsCreated = false
    var initialized = false

    var maxFramesPerSlice = Property(AudioDefaultMaxFramesPerSlice, writable: true, loggingLabel:"maxFramesPerSlice")
    var hostIdentifier = ConvertingProperty(HostIdentifier(hostName: "", hostVersion: AUNumVersion()), writable: true, converter: AUHostIdentifierConverter(), loggingLabel: "hostIdentifier")



    init(_ instance: AudioComponentInstance, numInputElements: UInt32 = 1, numOutputElements: UInt32 = 1, numGroupElements: UInt32 = 0) throws {
        self.instance = instance
        self.initParams = AudioUnitBaseInitParams(numInputElements: numInputElements, numOutputElements: numOutputElements)
        try createElements()
        registerPropertyObservers()
    }

    func initialize() throws {
        Log.debug("Initializing component")

        guard !initialized else {
            Log.debug("Initialization skipped")
            return
        }
        
        try reallocateBuffers()
        initialized = true
    }

    func uninitialize() {
        Log.debug("Uninitializing component")
        initialized = false
    }

    func reset(scope: AudioUnitScope, element: AudioUnitElement) throws {
        Log.debug("Reset")
    }

    func getScope(id: AudioUnitScope) -> AudioScope? {
        switch id {
        case kAudioUnitScope_Input:
            return inputs
        case kAudioUnitScope_Output:
            return outputs
        default:
            return nil
        }
    }

    func getInput(id: Int) -> InputAudioElement? {
        return inputs?.getElement(id) as? InputAudioElement
    }

    func getOutput(id: Int) -> OutputAudioElement? {
        return outputs?.getElement(id) as? OutputAudioElement
    }

    //MARK: - Elements
    func createElements() throws {
        guard !elementsCreated else {return}

        maxFramesPerSlice.onChange {[weak self] _ in
            if self?.buffersAllocated ?? false {
                do {
                    try self?.reallocateBuffers()
                } catch let error {
                    Log.debug("Failed to reallocate buffers: \(error)")
                }
            }
        }

        try createScopes()

        elementsCreated = true
    }

    func createScopes() throws {
        inputs = try InputAudioScope(id: kAudioUnitScope_Input, parent: self, elementType: InputAudioElement.self, numElements: initParams.numInputElements)
        outputs = try AudioScope(id: kAudioUnitScope_Output, parent: self, elementType: OutputAudioElement.self, numElements: initParams.numOutputElements)
    }


    //MARK: - Buffers
    func reallocateBuffers() throws {
        try createElements()

        outputs?.allocateBuffers()
        inputs?.allocateBuffers()
        buffersAllocated = true
    }


    //MARK: - Properties

    func properties() -> [AudioUnitPropertyID : PropertyType] {
        return [
            kAudioUnitProperty_MaximumFramesPerSlice: maxFramesPerSlice,
            kAudioUnitProperty_AUHostIdentifier: hostIdentifier
        ]
    }

    func notifyPropertyChanged(id: AudioUnitPropertyID) {
        notifyPropertyChanged(
            QualifiedPropertyID(
                propertyID: id,
                scopeID: 0,
                elementID: 0,
                audioUnit: instance))
    }
}

extension AudioUnitBase {
    func getExtraProperty(id: QualifiedPropertyID) throws -> OutputData {

        guard let scope = getScope(id.scopeID) else {throw AudioUnitError.InvalidScope}
        return try scope.getProperty(id)
    }

    func getExtraPropertyInfo(id: QualifiedPropertyID) throws -> OutputDataDescription {

        guard let scope = getScope(id.scopeID) else {throw AudioUnitError.InvalidScope}
        return try scope.getPropertyInfo(id)
    }

    func setExtraProperty(id: QualifiedPropertyID, data: InputData) throws {

        guard let scope = getScope(id.scopeID) else {throw AudioUnitError.InvalidScope}
        return try scope.setProperty(id, data: data)
    }
}