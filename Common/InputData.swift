//
//  InputData.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 12/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

struct InputData {
    let ptr: UnsafePointer<Void>
    let size: UInt32

    init(_ ptr: UnsafePointer<Void>, _ size: UInt32) {
        self.ptr = ptr
        self.size = size
    }
}