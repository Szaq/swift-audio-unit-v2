//
//  Framework.h
//  SwiftAudioUnitV2
//
//  Created by Łukasz Kwoska on 03/07/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

#ifndef Framework_h
#define Framework_h


#include <AudioToolbox/AudioToolbox.h>

#define Component(self) ((__bridge AudioUnitsManager *)((struct AudioComponentPlugInInstance *)self)->mInstanceStorage)

struct AudioUnitFunctions {
  __nullable AudioUnitInitializeProc initialize;
  __nullable AudioUnitUninitializeProc uninitialize;
  __nullable AudioUnitGetPropertyInfoProc getPropertyInfo;
  __nullable AudioUnitGetPropertyProc getProperty;
  __nullable AudioUnitSetPropertyProc setProperty;
  __nullable AudioUnitAddPropertyListenerProc addPropertyListener;
  __nullable AudioUnitRemovePropertyListenerProc removePropertyListener;
  __nullable AudioUnitRemovePropertyListenerWithUserDataProc removePropertyListenerWithUserData;

  __nullable AudioUnitGetParameterProc getParameter;
  __nullable AudioUnitSetParameterProc setParameter;
  __nullable AudioUnitScheduleParametersProc scheduleParameters;

  __nullable AudioUnitProcessProc process;
  __nullable AudioUnitProcessMultipleProc processMutltiple;

  __nullable AudioUnitRenderProc render;
  __nullable AudioUnitComplexRenderProc complexRender;
  __nullable AudioUnitAddRenderNotifyProc addRenderNotify;
  __nullable AudioUnitRemoveRenderNotifyProc removeRenderNotify;

  __nullable AudioUnitResetProc reset;

};

struct AudioComponentPlugInInstance {
  AudioComponentPlugInInterface interface;
  const void * _Nullable factory;
};


AudioComponentMethod __nullable	Lookup(SInt16 selector, struct AudioUnitFunctions functions);
NSObject * _Nonnull GetAudioComponentFactory(void * _Nonnull instance);
bool CheckListenersAreEqual(const AudioUnitPropertyListenerProc _Nonnull lhs, const AudioUnitPropertyListenerProc _Nonnull rhs) ;
bool CheckRenderCallbacksAreEqual(const AURenderCallback _Nonnull lhs, const AURenderCallback _Nonnull rhs) ;

#endif /* Framework_h */
