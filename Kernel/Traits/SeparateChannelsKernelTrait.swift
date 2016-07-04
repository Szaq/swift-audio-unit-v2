//
//  SeparateChannelsKernelTrait.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 08/06/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

class VoidKernelState : DefaultInitializable {
    required init() {
    }
}

protocol SeparateChannelsKernelTrait {
    associatedtype State: DefaultInitializable
    var state: [State] {get set}

    func process(input: UnsafeMutablePointer<Float32>,
                 output: UnsafeMutablePointer<Float32>,
                 state: State,
                 framesCount: Int) throws
}

extension SeparateChannelsKernelTrait {
    mutating func process(input: UnsafeMutableAudioBufferListPointer,
                          output: UnsafeMutableAudioBufferListPointer,
                          framesCount: Int) throws {
        let bufferSize = Int(min(input.first?.mDataByteSize ?? 0, output.first?.mDataByteSize ?? 0)) / sizeof(Float32)
        guard framesCount <= bufferSize else { throw AudioUnitError.TooManyFramesToProcess }

        let buffersCount = min(input.count, output.count)

        switch buffersCount - state.count {
        case let numberOfStatesToAdd where numberOfStatesToAdd > 0:
            (0..<numberOfStatesToAdd).forEach { _ in state.append(State()) }
        case let numberOfStatesToRemove where numberOfStatesToRemove < 0:
            state.removeLast(-numberOfStatesToRemove)
        default:
            break
        }
        
        for (inputBuffer, outputBuffer, state) in zip3(input.floatBufferDatas, output.floatBufferDatas, self.state) {
            try process(inputBuffer, output: outputBuffer, state: state, framesCount: framesCount)
        }
    }

    mutating func reset() {
        Log.debug("Removing all kernel states")
        state.removeAll()
    }

    var state: [VoidKernelState] {get{return [VoidKernelState]()} set{}}
}