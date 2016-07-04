//
//  AudioUnitError.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 09/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation
import AudioUnit

enum AudioUnitError: OSStatus, ErrorType {
    //Audio Unit errors
    case InvalidProperty      = -10879
    case InvalidParameter			= -10878
    case InvalidElement       = -10877
    case NoConnection         = -10876
    case FailedInitialization		= -10875
    case TooManyFramesToProcess	= -10874
    case InvalidFile          = -10871
    case UnknownFileType			= -10870
    case FileNotSpecified			= -10869
    case FormatNotSupported		= -10868
    case Uninitialized				= -10867
    case InvalidScope         = -10866
    case PropertyNotWritable		= -10865
    case CannotDoInCurrentContext	= -10863
    case InvalidPropertyValue		= -10851
    case PropertyNotInUse			= -10850
    case Initialized				= -10849
    case InvalidOfflineRender		= -10848
    case Unauthorized				= -10847
    case InstanceInvalidated  = -66749

    //Core audio errors
    case FileNotFound      = -43
    case FilePermission    = -54
    case TooManyFilesOpen  = -42
    case BadFilePath       = 0x21707468
    case BadParameter             = -50
    case MemoryFull           = -108
    case Unimplemented     = -4

    //Custom errors
    case InvalidKernel = -3
    case InvalidPropertySize = -2
    case UnknownError = -1
}

extension AudioUnitError {
    static func check(status: OSStatus) throws {
        guard status == noErr else {
            guard let error = AudioUnitError(rawValue: status) else {
                print("Unknown error \(status)")
                throw  AudioUnitError.UnknownError
            }
            throw error
        }
    }
}