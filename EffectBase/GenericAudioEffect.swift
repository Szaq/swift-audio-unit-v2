//
//  GenericAudioEffect.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 08/06/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

class GenericAudioEffect<KernelType where KernelType: Kernel, KernelType: DefaultInitializable>: AudioEffectBase, AudioComponent {

    required init(_ instance: AudioComponentInstance) throws {
        try super.init(instance)
    }

    override func createKernel() throws -> Kernel {
        return KernelType()
    }
}