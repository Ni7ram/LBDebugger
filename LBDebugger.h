/*******************************************************
 Created by Martin Cardozo on 5/9/17.
 Copyright (c) 2017 Litebyte. All rights reserved.
*******************************************************/

#ifndef LBDebugger_LBDebugger_h
#define LBDebugger_LBDebugger_h

#import "Message.h"

@interface LBDebugger : NSObject
    // INITIALIZERS
    - (id) initWithCanvas: (UIView*) canvas;
    - (id) initWithCanvas: (UIView*) canvas x: (int)_x y: (int)_y width: (int)_width height: (int)_height color: (UIColor*) _color;

    // PUBLIC METHODS
    - (void) toogle: (UIButton*)sender;
    - (void) logToConsole: (NSString*) text;
    - (void) logToConsole: (NSString*) text tab: (int) tabID;
    - (void) startMeasure;
    - (void) measure: (NSString*) codeID;
    - (void) setDevMode: (bool) value;
    - (void) loadTab: (int) tabID;
@end

#endif
