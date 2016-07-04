//
//  StreamBasicDescription.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 12/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation


enum CommonPCMFormat : Int {
    case Other		= 0
    case Float32	= 1
    case Int16		= 2
    case Fixed824	= 3
    case Float64	= 4
    case Int32		= 5
};

struct StreamBasicDescription {
    let audioStreamBasicDescription: AudioStreamBasicDescription

    var interleaved: Bool { return 0 == (audioStreamBasicDescription.mFormatFlags & kAudioFormatFlagIsNonInterleaved)}

    init(sampleRate: Double, numChannels: UInt32, pcmf: CommonPCMFormat, interleaved: Bool) throws {

        var wordSize: UInt32 = 0;
        var formatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;

        switch pcmf {
        case .Float32:
            wordSize = 4;
            formatFlags |= kAudioFormatFlagIsFloat;
        case .Float64:
            wordSize = 8;
            formatFlags |= kAudioFormatFlagIsFloat;
        case .Int16:
            wordSize = 2;
            formatFlags |= kAudioFormatFlagIsSignedInteger;
        case .Int32:
            wordSize = 4;
            formatFlags |= kAudioFormatFlagIsSignedInteger;
        case .Fixed824:
            wordSize = 4;
            formatFlags |= kAudioFormatFlagIsSignedInteger | (24 << kLinearPCMFormatFlagsSampleFractionShift);
        default:
            throw AudioUnitError.FormatNotSupported
        }

        let bitsPerChannel: UInt32 = wordSize * 8;
        var bytesPerFrame: UInt32 = 0
        var bytesPerPacket: UInt32 = 0

        if interleaved {
            bytesPerFrame = wordSize * numChannels
            bytesPerPacket = wordSize * numChannels
        } else {
            formatFlags |= kAudioFormatFlagIsNonInterleaved;
            bytesPerFrame = wordSize
            bytesPerPacket = wordSize
        }

        audioStreamBasicDescription = AudioStreamBasicDescription(mSampleRate: sampleRate,
                                                                  mFormatID: kAudioFormatLinearPCM,
                                                                  mFormatFlags: formatFlags,
                                                                  mBytesPerPacket: bytesPerPacket,
                                                                  mFramesPerPacket: 1,
                                                                  mBytesPerFrame: bytesPerFrame,
                                                                  mChannelsPerFrame: numChannels,
                                                                  mBitsPerChannel: bitsPerChannel,
                                                                  mReserved: 0)
    }

    init(streamDesc: AudioStreamBasicDescription) {
        self.audioStreamBasicDescription = streamDesc
    }
}

extension StreamBasicDescription: CustomStringConvertible {
    var description: String { return "format: \(audioStreamBasicDescription.mFormatID.descriptionAudioFormatID)"
        + ":\(audioStreamBasicDescription.mFormatFlags.descriptionAudioFormatFlags), "
        + "channels: \(audioStreamBasicDescription.mChannelsPerFrame), "
        + "bytes-per-channel: \(audioStreamBasicDescription.mBitsPerChannel / 8), "
        + "bytes-per-frame: \(audioStreamBasicDescription.mBytesPerFrame)" }
}

extension AudioFormatID {
    var descriptionAudioFormatID: String {
        switch self {
        case kAudioFormatLinearPCM: return "LinearPCM"
        case kAudioFormatAC3: return "AC3"
        case kAudioFormat60958AC3: return "60958AC3"
        case kAudioFormatAppleIMA4: return "AppleIMA4"
        case kAudioFormatMPEG4AAC: return "MPEG4AAC"
        case kAudioFormatMPEG4CELP: return "MPEG4CELP"
        case kAudioFormatMPEG4HVXC: return "MPEG4HVXC"
        case kAudioFormatMPEG4TwinVQ: return "MPEG4TwinVQ"
        case kAudioFormatMACE3: return "MACE3"
        case kAudioFormatMACE6: return "MACE6"
        case kAudioFormatULaw: return "ULaw"
        case kAudioFormatALaw: return "ALaw"
        case kAudioFormatQDesign: return "QDesign"
        case kAudioFormatQDesign2: return "QDesign2"
        case kAudioFormatQUALCOMM: return "QUALCOMM"
        case kAudioFormatMPEGLayer1: return "MPEGLayer1"
        case kAudioFormatMPEGLayer2: return "MPEGLayer2"
        case kAudioFormatMPEGLayer3: return "MPEGLayer3"
        case kAudioFormatTimeCode: return "TimeCode"
        case kAudioFormatMIDIStream: return "MIDIStream"
        case kAudioFormatParameterValueStream: return "ParameterValueStream"
        case kAudioFormatAppleLossless: return "AppleLossless"
        case kAudioFormatMPEG4AAC_HE: return "MPEG4AAC_HE"
        case kAudioFormatMPEG4AAC_LD: return "MPEG4AAC_LD"
        case kAudioFormatMPEG4AAC_ELD: return "MPEG4AAC_ELD"
        case kAudioFormatMPEG4AAC_ELD_SBR: return "MPEG4AAC_ELD_SBR"
        case kAudioFormatMPEG4AAC_ELD_V2: return "MPEG4AAC_ELD_V2"
        case kAudioFormatMPEG4AAC_HE_V2: return "MPEG4AAC_HE_V2"
        case kAudioFormatMPEG4AAC_Spatial: return "MPEG4AAC_Spatial"
        case kAudioFormatAMR: return "AMR"
        case kAudioFormatAMR_WB: return "AMR_WB"
        case kAudioFormatAudible: return "Audible"
        case kAudioFormatiLBC: return "iLBC"
        case kAudioFormatDVIIntelIMA: return "DVIIntelIMA"
        case kAudioFormatMicrosoftGSM: return "MicrosoftGSM"
        case kAudioFormatAES3: return "AES3"
        case kAudioFormatEnhancedAC3: return "EnhancedAC3"
        default: return "AudioFormatID(\(Int(self)))"
        }
    }
}

extension AudioFormatFlags {
    var descriptionAudioFormatFlags: String {
        var descriptions = [String]()

        func addToDescriptionIfSet(flag: AudioFormatFlags, _ text: String) {
            if (self & flag) != 0 {
                descriptions.append(text)
            }
        }

        addToDescriptionIfSet(kAudioFormatFlagIsFloat, "IsFloat")
        addToDescriptionIfSet(kAudioFormatFlagIsBigEndian, "IsBigEndian")
        addToDescriptionIfSet(kAudioFormatFlagIsSignedInteger, "IsSignedInteger")
        addToDescriptionIfSet(kAudioFormatFlagIsPacked, "IsPacked")
        addToDescriptionIfSet(kAudioFormatFlagIsAlignedHigh, "IsAlignedHigh")
        addToDescriptionIfSet(kAudioFormatFlagIsNonInterleaved, "IsNonInterleaved")
        addToDescriptionIfSet(kAudioFormatFlagIsNonMixable, "IsNonMixable")
        addToDescriptionIfSet(kAudioFormatFlagsAreAllClear, "AreAllClear")

        return descriptions.joinWithSeparator("|")

    }
}