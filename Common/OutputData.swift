//
//  OutputData.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 09/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

struct OutputData {
    let data: UnsafeMutablePointer<UInt8>
    let size: UInt32

    init(data: UnsafeMutablePointer<Void>, size: UInt32) {
        self.data = UnsafeMutablePointer<UInt8>(data)
        self.size = size
    }

    init<T>(_ t: T) throws {
        size = UInt32(sizeof(T))

        let dataAsT = UnsafeMutablePointer<T>.alloc(Int(size))
        dataAsT.initialize(t)
        data = UnsafeMutablePointer<UInt8>(dataAsT)
    }

    func copyTo(outData: UnsafeMutablePointer<Void>, _ ioDataSize: UnsafeMutablePointer<UInt32>) throws {
        let maxSize = ioDataSize.memory
        guard self.size <= maxSize else {throw AudioUnitError.InvalidPropertySize}
        
        let size = min(self.size, maxSize)

        if outData != nil {
            let outDataAsUInt8 = UnsafeMutablePointer<UInt8>(outData)
            outDataAsUInt8.initializeFrom(data, count: Int(size))
        }

        ioDataSize.initialize(size)
    }
}