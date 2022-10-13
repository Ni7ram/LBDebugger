/*******************************************************
 Created by Martin Cardozo on 5/9/17.
 Copyright (c) 2017 Litebyte. All rights reserved.
 *******************************************************/

#ifndef LBDebugger_Tab_h
#define LBDebugger_Tab_h

#import "LBDebugger.h"

@interface Tab : UIButton
    //PROPERTIES
    @property UIButton* btn;
    
    // INITIALIZERS
    - (id) initWithCanvas: (UIView*) canvas x: (int)x  y: (int) y w: (int)w h: (int)h  ID: (int)idC color: (UIColor*) color title: (NSString*) title actionResponder: (LBDebugger*) responder;

    // PUBLIC METHODS
    - (void) on;
    - (void) off;
@end

#endif
