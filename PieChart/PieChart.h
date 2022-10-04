/*******************************************************
 Created by Martin Cardozo on 5/9/17.
 Copyright (c) 2017 Litebyte. All rights reserved.
 *******************************************************/

#ifndef PieChart_h
#define PieChart_h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MCPieChartView.h"

@interface PieChart : UIViewController <MCPieChartViewDataSource, MCPieChartViewDelegate>
    // PROPERTIES

    // METHODS
    - (id) initWithCanvas: (UIView*) canvas;
    - (void) show;
    - (void) hide;
    - (void) repositionWithX: (int)x y: (int)y w: (int)w h: (int)h;
    	- (void) reset;
@end

#endif
