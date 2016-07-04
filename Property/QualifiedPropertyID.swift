//
//  QualifiedPropertyID.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 13/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

struct QualifiedPropertyID: CustomStringConvertible{
    let propertyID: AudioUnitPropertyID
    let scopeID: AudioUnitScope
    let elementID: AudioUnitElement
    let audioUnit: AudioUnit?

    var description: String {
        if let audioUnit = audioUnit {
            return "\(propertyID.descriptionAudioUnitPropertyID) : (\(scopeID), \(elementID), \(audioUnit))"
        } else {
            return "\(propertyID.descriptionAudioUnitPropertyID) : (\(scopeID), \(elementID))"
        }
    }
}

extension AudioUnitPropertyID {
    var descriptionAudioUnitPropertyID: String {
        switch self {
        case kAudioUnitProperty_ClassInfo: return "kAudioUnitProperty_ClassInfo"
        case kAudioUnitProperty_MakeConnection: return "kAudioUnitProperty_MakeConnection"
        case kAudioUnitProperty_SampleRate: return "kAudioUnitProperty_SampleRate"
        case kAudioUnitProperty_ParameterList: return "kAudioUnitProperty_ParameterList"
        case kAudioUnitProperty_ParameterInfo: return "kAudioUnitProperty_ParameterInfo"
        case kAudioUnitProperty_CPULoad: return "kAudioUnitProperty_CPULoad"
        case kAudioUnitProperty_StreamFormat: return "kAudioUnitProperty_StreamFormat"
        case kAudioUnitProperty_ElementCount: return "kAudioUnitProperty_ElementCount"
        case kAudioUnitProperty_Latency: return "kAudioUnitProperty_Latency"
        case kAudioUnitProperty_SupportedNumChannels: return "kAudioUnitProperty_SupportedNumChannels"
        case kAudioUnitProperty_MaximumFramesPerSlice: return "kAudioUnitProperty_MaximumFramesPerSlice"
        case kAudioUnitProperty_ParameterValueStrings: return "kAudioUnitProperty_ParameterValueStrings"
        case kAudioUnitProperty_AudioChannelLayout: return "kAudioUnitProperty_AudioChannelLayout"
        case kAudioUnitProperty_TailTime: return "kAudioUnitProperty_TailTime"
        case kAudioUnitProperty_BypassEffect: return "kAudioUnitProperty_BypassEffect"
        case kAudioUnitProperty_LastRenderError: return "kAudioUnitProperty_LastRenderError"
        case kAudioUnitProperty_SetRenderCallback: return "kAudioUnitProperty_SetRenderCallback"
        case kAudioUnitProperty_FactoryPresets: return "kAudioUnitProperty_FactoryPresets"
        case kAudioUnitProperty_RenderQuality: return "kAudioUnitProperty_RenderQuality"
        case kAudioUnitProperty_HostCallbacks: return "kAudioUnitProperty_HostCallbacks"
        case kAudioUnitProperty_InPlaceProcessing: return "kAudioUnitProperty_InPlaceProcessing"
        case kAudioUnitProperty_ElementName: return "kAudioUnitProperty_ElementName"
        case kAudioUnitProperty_SupportedChannelLayoutTags: return "kAudioUnitProperty_SupportedChannelLayoutTags"
        case kAudioUnitProperty_PresentPreset: return "kAudioUnitProperty_PresentPreset"
        case kAudioUnitProperty_DependentParameters: return "kAudioUnitProperty_DependentParameters"
        case kAudioUnitProperty_InputSamplesInOutput: return "kAudioUnitProperty_InputSamplesInOutput"
        case kAudioUnitProperty_ShouldAllocateBuffer: return "kAudioUnitProperty_ShouldAllocateBuffer"
        case kAudioUnitProperty_FrequencyResponse: return "kAudioUnitProperty_FrequencyResponse"
        case kAudioUnitProperty_ParameterHistoryInfo: return "kAudioUnitProperty_ParameterHistoryInfo"
        case kAudioUnitProperty_NickName: return "kAudioUnitProperty_NickName"
        case kAudioUnitProperty_OfflineRender: return "kAudioUnitProperty_OfflineRender"
        case kAudioUnitProperty_ParameterIDName: return "kAudioUnitProperty_ParameterIDName"
        case kAudioUnitProperty_ParameterStringFromValue: return "kAudioUnitProperty_ParameterStringFromValue"
        case kAudioUnitProperty_ParameterClumpName: return "kAudioUnitProperty_ParameterClumpName"
        case kAudioUnitProperty_ParameterValueFromString: return "kAudioUnitProperty_ParameterValueFromString"
        case kAudioUnitProperty_ContextName: return "kAudioUnitProperty_ContextName"
        case kAudioUnitProperty_PresentationLatency: return "kAudioUnitProperty_PresentationLatency"
        case kAudioUnitProperty_ClassInfoFromDocument: return "kAudioUnitProperty_ClassInfoFromDocument"
        case kAudioUnitProperty_RequestViewController: return "kAudioUnitProperty_RequestViewController"
        case kAudioUnitProperty_ParametersForOverview: return "kAudioUnitProperty_ParametersForOverview"
        case kAudioUnitProperty_FastDispatch: return "kAudioUnitProperty_FastDispatch"
        case kAudioUnitProperty_SetExternalBuffer: return "kAudioUnitProperty_SetExternalBuffer"
        case kAudioUnitProperty_GetUIComponentList: return "kAudioUnitProperty_GetUIComponentList"
        case kAudioUnitProperty_CocoaUI: return "kAudioUnitProperty_CocoaUI"
        case kAudioUnitProperty_IconLocation: return "kAudioUnitProperty_IconLocation"
        case kAudioUnitProperty_AUHostIdentifier: return "kAudioUnitProperty_AUHostIdentifier"
        case kAudioUnitProperty_MIDIOutputCallbackInfo: return "kAudioUnitProperty_MIDIOutputCallbackInfo"
        case kAudioUnitProperty_MIDIOutputCallback: return "kAudioUnitProperty_MIDIOutputCallback"
        default: return "AudioUnitPropertyID(\(Int(self)))"
        }
    }
}