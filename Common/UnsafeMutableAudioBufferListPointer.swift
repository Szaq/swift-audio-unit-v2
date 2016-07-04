//
//  UnsafeMutableAudioBuffer.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 01/07/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

extension UnsafeMutableAudioBufferListPointer {
    var floatBufferDatas: [UnsafeMutablePointer<Float32>] {
        return map { UnsafeMutablePointer<Float32>($0.mData) }
    }

    static func allocate(format: StreamBasicDescription, framesCount: UInt32) -> UnsafeMutableAudioBufferListPointer {
        let streamCount = format.interleaved ? 1 : Int(format.audioStreamBasicDescription.mChannelsPerFrame)
        let channelsPerStreamCount = format.interleaved ? format.audioStreamBasicDescription.mChannelsPerFrame : UInt32(1)
        let bufferSize = calculateBufferSize(format, framesCount: framesCount)

        let audioBufferList = AudioBufferList.allocate(maximumBuffers: streamCount)
        for index in 0 ..< streamCount {
            audioBufferList[index] = AudioBuffer(
                mNumberChannels: channelsPerStreamCount,
                mDataByteSize: bufferSize,
                mData: UnsafeMutablePointer<UInt8>.alloc(Int(bufferSize)))
        }
        return audioBufferList
    }

    func setBufferSize(format: StreamBasicDescription, framesCount: UInt32) {
        let streamCount = format.interleaved ? 1 : Int(format.audioStreamBasicDescription.mChannelsPerFrame)

        let bufferSize = UnsafeMutableAudioBufferListPointer.calculateBufferSize(format, framesCount: framesCount)

        for index in 0 ..< streamCount {
            self[index].mDataByteSize = bufferSize
        }
    }

    /**
     Copy content of this buffer to other buffer.

     - parameter to: BufferList to copy to

     - throws: AudioUnitError
     */
    func copy(to destination: UnsafeMutableAudioBufferListPointer) throws {
        for (var destBuffer, sourceBuffer) in zip(destination, self) {
            try sourceBuffer.copy(to: &destBuffer)
        }
    }

    private static func calculateBufferSize(format: StreamBasicDescription, framesCount: UInt32) -> UInt32 {
        return framesCount * format.audioStreamBasicDescription.mBytesPerFrame
    }
}
