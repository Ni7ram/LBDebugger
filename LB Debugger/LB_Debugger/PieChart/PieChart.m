/******************************************************************
 Created by Martin Cardozo on 5/9/17.
 Copyright (c) 2017 Litebyte. All rights reserved.
 *****************************************************************/

#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "MCPieChartView.h"
#import "PieChart.h"

/******************************************************************
                        INTERFACE
******************************************************************/

#pragma mark - Interface

@interface PieChart ()
    @property UIView* canvas;
    @property CGRect frame;
    @property MCPieChartView* pieChartView;

    @property (strong, nonatomic) NSMutableArray *values;
    @property (strong, nonatomic) NSMutableArray *labels;
    @property (strong, nonatomic) NSMutableArray *colors;

    @property (nonatomic) BOOL inserting;
@end

/******************************************************************
                        IMPLEMENTATION
******************************************************************/

#pragma mark - Implementation

const int PIECHART_MARGIN = 140;

@implementation PieChart {
    
}

/*****************************************************************
                CONSTRUCTORS / INITIALIZERS
*****************************************************************/

#pragma mark - Initializers

- (id) init {
    return [super init];
}

- (id) initWithCanvas: (UIView*) canvas {
    self = [self init];
    
    _canvas = canvas;
    [self initPieChart];
    
    return self;
}

- (void) initPieChart {
    // INIT PIE CHART
    _pieChartView = [[MCPieChartView alloc] initWithFrame: _canvas.frame];
    _values   = [[NSMutableArray alloc] init];
    _labels   = [[NSMutableArray alloc] init];

    // INIT PIE CHART
    _pieChartView.dataSource         = self;
    _pieChartView.delegate           = self;
    _pieChartView.animationDuration  = 0.5;
    _pieChartView.sliceColor         = [MCUtil flatWetAsphaltColor];
    _pieChartView.borderColor        = [UIColor blackColor];
    _pieChartView.selectedSliceColor = [MCUtil flatSunFlowerColor];
    _pieChartView.textColor          = [MCUtil flatSunFlowerColor];
    _pieChartView.selectedTextColor  = [MCUtil flatWetAsphaltColor];
    _pieChartView.borderPercentage   = 0.01;
    _pieChartView.showText           = YES;
    
    // RENDER
    _pieChartView.alpha = 0;
    [_canvas addSubview: _pieChartView];
}

/*****************************************************************
                        PUBLIC METHODS
 *****************************************************************/

#pragma mark - Public Methods

- (void) show {
    [UIView animateWithDuration: 0.3 delay: 0.2 options: UIViewAnimationOptionCurveEaseOut animations:^() {
        _pieChartView.alpha = 1;
        
        CGRect newFrame = _pieChartView.frame;
        newFrame.origin.y -= 300;
        [_pieChartView setFrame: newFrame];
    } completion: ^(BOOL finished) {
        [self addSliceWithLabel: @"Hola" value: 10];
    }];
}

- (void) hide {
    // CUANDO ANIMES EL TEXTVIEW ESTE EFECTO VA A QUEDAR BIEN
    [UIView animateWithDuration: 0.5 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations:^() {
        _pieChartView.alpha = 0;
        
        CGRect newFrame = _pieChartView.frame;
        newFrame.origin.y += 300;
        [_pieChartView setFrame: newFrame];
    } completion: ^(BOOL finished) {}];
}

- (void) repositionWithX: (int)x y: (int)y w: (int)w h: (int)h {
    CGRect newFrame = CGRectMake(x, y+h/2+350, w, h/2);
    _pieChartView.frame = newFrame;
}

- (void) reset {
    _values = [[NSMutableArray alloc] init];
    _labels = [[NSMutableArray alloc] init];
    [_pieChartView reloadData];
}


/*****************************************************************
                        PRIVATE METHODS
*****************************************************************/

#pragma mark - Private Methods

- (NSInteger) numberOfSlicesInPieChartView: (MCPieChartView*) pieChartView {
    return _values.count;
}

- (void) addSliceWithLabel: (NSString*) label value: (int) value {
    // ADD DATA
    [_values addObject: [NSNumber numberWithInt: value]];
    [_labels addObject: label];
    
    // RELOAD
    [_pieChartView reloadData];
}

- (UIColor*) pieChartView: (MCPieChartView*) pieChartView colorForTextAtIndex: (NSInteger) index {
    //if (index == 0) {
    //    return [UIColor blackColor];
    //}
    return [UIColor lightGrayColor];
}

- (CGFloat) pieChartView: (MCPieChartView*) pieChartView valueForSliceAtIndex: (NSInteger) index {
    return [[_values objectAtIndex: index] floatValue];
}

- (NSString*) pieChartView: (MCPieChartView*) pieChartView textForSliceAtIndex: (NSInteger) index {
    return [_labels objectAtIndex: index];
}

@end
