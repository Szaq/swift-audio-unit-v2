//
//  AudioBuffer.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 09/06/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

extension AudioBuffer {
    func copy(inout to destination: AudioBuffer) throws {
        guard mDataByteSize <= destination.mDataByteSize else {throw AudioUnitError.TooManyFramesToProcess}
        let destData = UnsafeMutablePointer<UInt8>(destination.mData)
        let sourceData = UnsafeMutablePointer<UInt8>(mData)
        
        if destData != sourceData {
            destData.initializeFrom(sourceData, count: Int(mDataByteSize))
            destination.mDataByteSize = mDataByteSize
        }
    }

    func dumpFirst<TYPE>(type: TYPE.Type, count: Int) -> String {
        let sourceData = UnsafeMutablePointer<TYPE>(mData)
        let itemsInData = Int(mDataByteSize) / sizeof(TYPE)

        return (0..<min(itemsInData, count)).map { "\(sourceData[$0])"}.joinWithSeparator(", ")
    }
}