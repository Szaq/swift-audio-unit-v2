//
//  InputAudioElement.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 10/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation
import AudioUnit

class InputAudioElement: AudioElement {
    var connection: AudioUnitConnection?
    let renderCallback: Property<AURenderCallbackStruct?>
    
    required init(_ id: AudioUnitElement, parent: AudioScope) throws {
        renderCallback = NilableProperty(nil, writable: true)
        try super.init(id, parent: parent)
    }

    func setConnection(connection: AudioUnitConnection) {
        Log.debug("Setting connection to: \(connection)")
        guard connection.sourceAudioUnit != nil else {
            disconnect();
            return
        }

        self.connection = connection
        allocateBuffer()

    }

    func disconnect() {
        deallocateBuffer()
    }
    
    override func properties() -> [AudioUnitPropertyID : PropertyType] {
        return super.properties() + [kAudioUnitProperty_SetRenderCallback : renderCallback]
    }

    func pull(inout actionFlags: AudioUnitRenderActionFlags,
                    _ timestamp: AudioTimeStamp,
                      _ elementID: UInt32,
                        _ framesCount: UInt32) throws -> UnsafeMutableAudioBufferListPointer {


        var localTimestamp = timestamp

        buffer.setBufferSize(streamFormat.value, framesCount: framesCount)
        let bufferPointer = buffer.unsafeMutablePointer
        
        if let connection = connection {
            Log.debug("Pull from connection")


            try AudioUnitError.check(AudioUnitRender(connection.sourceAudioUnit,
                &actionFlags,
                &localTimestamp,
                connection.sourceOutputNumber,
                framesCount,
                bufferPointer))

        } else if let renderCallback = renderCallback.value {

            //Log.debug("Pull from callback for timestamp: \(localTimestamp.mSampleTime) | actionFlags:\(actionFlags) | frames: \(framesCount)")

            /*buffer.floatBufferDatas.forEach { floatBuffer in
                for index in 0 ..< Int(framesCount) {
                    floatBuffer[index] = Float32(index)
                }
            }*/

            try AudioUnitError.check(renderCallback.inputProc(renderCallback.inputProcRefCon,
                &actionFlags,
                &localTimestamp,
                elementID,
                framesCount,
                bufferPointer))
        } else {
            Log.debug("Nowhere to pull from")
            throw AudioUnitError.NoConnection
        }

        if actionFlags.contains(.UnitRenderAction_OutputIsSilence) {
            Log.debug("Pulled silence")
        }

        /*


        let descriptions = UnsafeMutableAudioBufferListPointer(bufferPointer).map {"\($0.mDataByteSize)| \($0.dumpFirst(Float32.self, count: 10))"}.joinWithSeparator("\n")
        Log.debug("Done. got: \(descriptions)\n")
        let descriptionsBuffer = buffer.buffers.map {"\($0.mDataByteSize)| \($0.dumpFirst(Float32.self, count: 10))"}.joinWithSeparator("\n")
        Log.debug("Done. got:\n - ptr: \(descriptions)\n - bfr: \(descriptionsBuffer)")
 */
         return UnsafeMutableAudioBufferListPointer(bufferPointer)
    }
}