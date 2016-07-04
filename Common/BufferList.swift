//
//  AudioBuffer.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 10/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation
import AudioUnit



class BufferList {
    func audioBufferListPointer(format: StreamBasicDescription, framesCount: UInt32) -> UnsafeMutableAudioBufferListPointer {
        return createAudioBufferList(&buffers, count: buffers.count, format: format, framesCount:  framesCount)
    }


    var buffers: [AudioBuffer] = []

    var floatBufferDatas: [UnsafeMutablePointer<Float32>] {
        return buffers.map { UnsafeMutablePointer<Float32>($0.mData) }
    }

    func allocate(format: StreamBasicDescription, framesCount: UInt32) {
        let streamCount = format.interleaved ? 1 : Int(format.audioStreamBasicDescription.mChannelsPerFrame)
        let channelsPerStreamCount = format.interleaved ? format.audioStreamBasicDescription.mChannelsPerFrame : UInt32(1)
        let bufferSize = calculateBufferSize(format, framesCount: framesCount)

        buffers.removeAll()
        buffers.reserveCapacity(streamCount)
        for _ in 0 ..< streamCount {
            buffers.append(AudioBuffer(
                mNumberChannels: channelsPerStreamCount,
                mDataByteSize: bufferSize,
                mData: UnsafeMutablePointer<UInt8>.alloc(Int(bufferSize))))
        }
    }

    func deallocate() {
        buffers = []
    }

    /**
     Copy content of this buffer to other buffer.

     - parameter to: BufferList to copy to

     - throws: AudioUnitError
     */
    func copy(to destination: BufferList) throws {
        for (var destBuffer, sourceBuffer) in zip(destination.buffers, buffers) {
            try sourceBuffer.copy(to: &destBuffer)
        }
    }

    /**
     This is hack to create variable sized AudioBufferList.

     - parameter buffers: Buffers to pass
     - parameter count:   Number of buffers
     - parameter framesCount: Number of frames in buffer requested.

     - returns: AudioBufferList like structure.
     */
    private func createAudioBufferList(buffers: UnsafeMutablePointer<AudioBuffer>,
                                       count: Int,
                                       format: StreamBasicDescription,
                                       framesCount: UInt32) -> UnsafeMutableAudioBufferListPointer {

        let expectedBufferSize = calculateBufferSize(format, framesCount: framesCount)

        let buffersList = AudioBufferList.allocate(maximumBuffers: count)
        (0..<count).forEach { index in
            buffersList[index] = AudioBuffer(mNumberChannels: buffers[index].mNumberChannels,
                mDataByteSize: min(buffers[index].mDataByteSize, expectedBufferSize),
                mData: buffers[index].mData)
        }
        
        return buffersList
    }

    private func calculateBufferSize(format: StreamBasicDescription, framesCount: UInt32) -> UInt32 {
        return framesCount * format.audioStreamBasicDescription.mBytesPerFrame
    }
}