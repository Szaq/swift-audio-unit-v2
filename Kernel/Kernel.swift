//
//  Kernel.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 22/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

protocol Kernel {
    mutating func process(input: UnsafeMutableAudioBufferListPointer,
                          output: UnsafeMutableAudioBufferListPointer,
                          framesCount: Int) throws
    
    mutating func reset()
}