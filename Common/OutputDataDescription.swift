//
//  OutputDataDescription.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 10/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

struct OutputDataDescription {
    let size: UInt32
    let writable: Bool

    init<T>(_ t: T, writable: Bool) throws {
        size = UInt32(sizeof(T))
        self.writable = writable
    }

    func copyTo(outDataSize: UnsafeMutablePointer<UInt32>, _ outWritable: UnsafeMutablePointer<DarwinBoolean>) throws {
        if outDataSize != nil {
            outDataSize.initialize(size)
        }

        if outWritable != nil {
            outWritable.initialize(DarwinBoolean(writable))
        }
    }

}