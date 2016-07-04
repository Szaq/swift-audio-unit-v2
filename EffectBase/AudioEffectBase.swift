//
//  AUEffectBase.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 06/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation
import AudioUnit

class AudioEffectBase: AudioUnitBase {
   
    var mainInput: InputAudioElement!
    var mainOutput: OutputAudioElement!
    var kernels: [Kernel] = []

    private(set) var bypass = ConvertingProperty(false, writable: true, converter: BoolUInt32Converter())
    private(set) var inplace = ConvertingProperty(false, writable: true, converter: BoolUInt32Converter())
    private(set) var latency = Property<Float64>(0.0, writable: false)
    private(set) var tailTime = Property<Float64>(0.0, writable: false)

    required init(_ instance: AudioComponentInstance) throws {
        try super.init(instance)
    }

    override func initialize() throws {
        try super.initialize()

        guard let numInputs = getInput(0)?.streamFormat.value.audioStreamBasicDescription.mChannelsPerFrame,
            numOutputs = getOutput(0)?.streamFormat.value.audioStreamBasicDescription.mChannelsPerFrame
            where numOutputs == numInputs && numOutputs != 0 else { throw AudioUnitError.FormatNotSupported }

        Log.debug("Initialized effect with: \(numInputs) -> \(numOutputs)")

        mainOutput = getOutput(0);
        mainInput = getInput(0);

        try setupKernels();

        bypass.onChange {[weak self] _ in
            if !(self?.bypass.value ?? false) {
                do {
                    try self?.reset(0, element: 0)
                } catch let error {
                    Log.error("Failed to reset audio effect due to bypass: \(error)")
                }
            }
        }
    }

    override func uninitialize() {
        super.uninitialize()

        cleanupKernels()
    }

    override func reset(scope: AudioUnitScope, element: AudioUnitElement) throws {
        try super.reset(scope, element: element)

        resetKernels()
    }

    //MARK: - Rendering

    func render(inout actionFlags: AudioUnitRenderActionFlags,
                      timeStamp: AudioTimeStamp,
                      outputBusNumber: UInt32,
                      framesCount: UInt32,
                      inout data: UnsafeMutableAudioBufferListPointer) throws {
        guard framesCount <= maxFramesPerSlice.value else {throw AudioUnitError.TooManyFramesToProcess}

        var preRenderActionFlags = actionFlags.union(AudioUnitRenderActionFlags.UnitRenderAction_PreRender)
        var localTimestamp = timeStamp
        notifyRender(&preRenderActionFlags, timeStamp: &localTimestamp, busNumber: outputBusNumber, framesCount: framesCount, data: data)

        let index = 0
        //for (index, output) in outputs.elements.enumerate() {
        guard let input = getInput(index), let output = getOutput(Int(outputBusNumber)) else {
            Log.debug("No input for specified output")
            throw AudioUnitError.NoConnection
        }

        //1. Pull Input
        let inputBuffer = try input.pull(&actionFlags, timeStamp, 0, framesCount)

        //2. Process
        var outputBuffer = output.buffer
        switch (bypass.value, inplace.value) {
        case (true, true):
            outputBuffer = inputBuffer

        case (true, false):
            try inputBuffer.copy(to: outputBuffer)

        case (false, true):
            try kernels[index].process(inputBuffer, output: inputBuffer, framesCount: Int(framesCount))
            outputBuffer = inputBuffer

        case (false, false):
            try kernels[index].process(inputBuffer, output: outputBuffer, framesCount: Int(framesCount))
        }

        //3. Write Output
        data = outputBuffer
        data.setBufferSize(output.streamFormat.value, framesCount: framesCount)
        
        //}
        var postRenderActionFlags = actionFlags.union(AudioUnitRenderActionFlags.UnitRenderAction_PostRender)
        notifyRender(&postRenderActionFlags, timeStamp: &localTimestamp, busNumber: outputBusNumber, framesCount: framesCount, data: data)
    }

    func process(inout actionFlags: AudioUnitRenderActionFlags,
                       timeStamp: AudioTimeStamp,
                       numberFrames: UInt32,
                       inout data: AudioBufferList) throws  {
        throw AudioUnitError.Unimplemented
    }


    //MARK: - Kernels
    func setupKernels() throws {
        Log.debug("Seting up kernels")

        let numberOfChannels = Int(mainOutput.streamFormat.value.audioStreamBasicDescription.mChannelsPerFrame)

        switch numberOfChannels - kernels.count {
        case let numberOfkernelsToRemove where numberOfkernelsToRemove < 0 :
            kernels.removeLast(-numberOfkernelsToRemove)
        case let numberOfKernelsToAdd:
            let kernelsToAdd = try (0..<numberOfKernelsToAdd).map {_ in try createKernel()}
            kernels.appendContentsOf(kernelsToAdd)
        }
    }

    func createKernel() throws -> Kernel {
        throw AudioUnitError.InvalidKernel
    }

    func cleanupKernels() {
        Log.debug("Cleaning up kernels")
        kernels = []
    }

    func resetKernels() {
        Log.debug("Resetting kernels")
        for var kernel in kernels {
            kernel.reset()
        }
    }

    //MARK: - Properties

    override func properties() -> [AudioUnitPropertyID : PropertyType] {
        return super.properties() + [
            kAudioUnitProperty_BypassEffect: bypass,
            kAudioUnitProperty_InPlaceProcessing: inplace,
            kAudioUnitProperty_Latency: latency,
            kAudioUnitProperty_TailTime: tailTime,
        ]
    }

}
