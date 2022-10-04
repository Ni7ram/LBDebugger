/******************************************************************
 Created by Martin Cardozo on 5/9/17.
 Copyright (c) 2017 Litebyte. All rights reserved.
 ******************************************************************/

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Tab.h"

/******************************************************************
                            INTERFACE
 ******************************************************************/

#pragma mark - Interface

@interface Tab ()
    // PRIVATE PROPERTIES
    @property UIView* canvas;
    @property UIView* bottomLine;
    @property NSString* title;
    @property UIColor* color;
    @property LBDebugger* responder;

    // PRIVATE METHODS
    - (void) clic;
@end

/******************************************************************
                        IMPLEMENTATION
 ******************************************************************/

@implementation Tab {
    // define private instance variables
}

/*****************************************************************
                CONSTRUCTORS / INITIALIZERS
 *****************************************************************/

#pragma mark - Constructor
	
- (id) initWithCanvas: (UIView*) canvas x: (int)x  y: (int) y w: (int)w h: (int)h  ID: (int)idC color: (UIColor*) color title: (NSString*) title actionResponder: (LBDebugger*) responder {
    
    if (self = [super initWithFrame: CGRectMake(x, y, w, h)]) {
        _canvas    = canvas;
        _title     = title;
        _color     = color;
        _responder = responder;
        self.tag   = idC;
    }

    _btn = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    _btn.frame = CGRectMake(x, y, w, h);
    _btn.layer.cornerRadius = 5;
    _btn.backgroundColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.7];
    _btn.layer.cornerRadius = 2;
    _btn.alpha = 0;
    
    // TEXT
    [_btn setTitle: _title forState: UIControlStateNormal];
    UIFont* font = _btn.titleLabel.font;
    _btn.titleLabel.font = [font fontWithSize: 12];
    
    // LINE
    _bottomLine = [[UIView alloc] initWithFrame: CGRectMake(0, h, w, 1)];
    _bottomLine.backgroundColor = _color;
    _bottomLine.alpha = 0;
    [_btn addSubview: _bottomLine];

    // ACTION
    [_btn addTarget: self action: @selector(clic) forControlEvents: UIControlEventTouchDown];

    // ADD GRAPHIC
    [canvas addSubview: _btn];
    
    // TRIGGER ANIMATION
    [UIView animateWithDuration: 0.5 delay: 0.5 options: UIViewAnimationOptionCurveEaseOut animations:^() {
        _btn.alpha = 1;
    } completion: ^(BOOL finished) {} ];
    
    return self;
}

/*****************************************************************
                        PUBLIC METHODS
*****************************************************************/

#pragma mark - Public Methods

- (void) on {
    [UIView animateWithDuration: 0.3 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations:^() {
        _bottomLine.alpha = 1;
        _btn.titleLabel.textColor = [UIColor blueColor];
    } completion: ^(BOOL finished) {}];
}

- (void) off {
    [UIView animateWithDuration: 0.5 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations:^() {
        _bottomLine.alpha = 0;
        _btn.titleLabel.textColor = [UIColor colorWithRed: 255 green: 255 blue: 255 alpha: 1];
    } completion: ^(BOOL finished) {}];
}

/*****************************************************************
                        PRIVATE METHODS
*****************************************************************/

#pragma mark - Private Methods

- (void) clic {
    [_responder loadTab: (int)self.tag];
}

@end
