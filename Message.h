/*******************************************************
 Created by Martin Cardozo on 5/9/17.
 Copyright (c) 2017 Litebyte. All rights reserved.
 *******************************************************/

#ifndef LBDebugger_Message_h
#define LBDebugger_Message_h

@interface Message : NSObject
    // PUBLIC PROPERTIES
    @property NSString* message;
    @property int tab;

    // PUBLIC METHODS
    - (id) initWithMessage: (NSString*) message tab: (int) tab;
    - (NSString*) getText;
@end

#endif
