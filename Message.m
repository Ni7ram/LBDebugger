/******************************************************************
 Created by Martin Cardozo on 5/9/17.
 Copyright (c) 2017 Litebyte. All rights reserved.
 ******************************************************************/

#import <Foundation/Foundation.h>
#import "Message.h"

/******************************************************************
                        INTERFACE
******************************************************************/

#pragma mark - Interface

@interface Message ()
    // define private properties
    // define private methods
@end

/******************************************************************
                        IMPLEMENTATION
******************************************************************/

@implementation Message {
    // define private instance variables
}

/*****************************************************************
            CONSTRUCTORS / INITIALIZERS
*****************************************************************/

#pragma mark - Initializer

- (id) initWithMessage: (NSString*) message tab: (int) tab {
    
    if (self = [super init]) {
        _message = message;
        _tab     = tab;
    }
    
    return self;
}

/*****************************************************************
                        PRIVATE METHODS
 *****************************************************************/

#pragma mark - Private Methods

- (NSString*) getText {
    return _message;
}

@end
