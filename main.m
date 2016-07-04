//
//  Test.c
//  TestConvolution
//
//  Created by Łukasz Kwoska on 20/01/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

#include <stdio.h>
#include "Framework.h"
#include "SpinalReverb-Swift.h"

AudioComponentFactoryFacade *GetAudioComponentFactory(void * instance) {
    struct AudioComponentPlugInInstance *pluginInstance = (struct AudioComponentPlugInInstance *)instance;
    AudioComponentFactoryFacade *factory = pluginInstance->factory;
    return factory;
}

AudioComponentMethod __nullable	Lookup(SInt16 selector, struct AudioUnitFunctions functions) {
    switch(selector) {
        case kAudioUnitInitializeSelect:
            return (AudioComponentMethod)functions.initialize;
        case kAudioUnitUninitializeSelect:
            return (AudioComponentMethod)functions.uninitialize;
        case kAudioUnitGetPropertyInfoSelect:
            return (AudioComponentMethod)functions.getPropertyInfo;
        case kAudioUnitGetPropertySelect:
            return (AudioComponentMethod)functions.getProperty;
        case kAudioUnitSetPropertySelect:
            return (AudioComponentMethod)functions.setProperty;
        case kAudioUnitAddPropertyListenerSelect:
            return (AudioComponentMethod)functions.addPropertyListener;
        case kAudioUnitRemovePropertyListenerSelect:
            return (AudioComponentMethod)functions.removePropertyListener;
        case kAudioUnitRemovePropertyListenerWithUserDataSelect:
            return (AudioComponentMethod)functions.removePropertyListenerWithUserData;
        case kAudioUnitAddRenderNotifySelect:
            return (AudioComponentMethod)functions.addRenderNotify;
        case kAudioUnitRemoveRenderNotifySelect:
            return (AudioComponentMethod)functions.removeRenderNotify;
        case kAudioUnitGetParameterSelect:
            return (AudioComponentMethod)functions.getParameter;
        case kAudioUnitSetParameterSelect:
            return (AudioComponentMethod)functions.setParameter;
        case kAudioUnitScheduleParametersSelect:
            return (AudioComponentMethod)functions.scheduleParameters;
        case kAudioUnitRenderSelect:
            return (AudioComponentMethod)functions.render;
        case kAudioUnitComplexRenderSelect:
            return (AudioComponentMethod)functions.complexRender;
        case kAudioUnitResetSelect:
            return (AudioComponentMethod)functions.reset;
        case kAudioUnitProcessSelect:
            return (AudioComponentMethod)functions.process;
        case kAudioUnitProcessMultipleSelect:
            return (AudioComponentMethod)functions.processMutltiple;
    }
    return nil;
}

bool CheckListenersAreEqual(AudioUnitPropertyListenerProc lhs, AudioUnitPropertyListenerProc rhs) {
    return lhs == rhs;
}

bool CheckRenderCallbacksAreEqual(const AURenderCallback _Nonnull lhs, const AURenderCallback _Nonnull rhs) {
    return lhs == rhs;
}

void * Factory(const AudioComponentDescription *inDesc) {

    if (!inDesc) {
        return NULL;
    }

    struct AudioComponentPlugInInstance *acpi = malloc(sizeof(struct AudioComponentPlugInInstance));
    AudioComponentFactoryFacade *factory = [AudioComponentFactoryFacade factory:*inDesc];
    struct AudioComponentPlugInInterface interface = [factory interface];

    acpi->interface.Open = interface.Open;
    acpi->interface.Close = interface.Close;
    acpi->interface.Lookup = interface.Lookup;
    acpi->interface.reserved = interface.reserved;
    acpi->factory = [factory retain];

    return acpi;
}
