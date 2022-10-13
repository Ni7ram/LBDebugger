//
//  ViewController.m
//  LB Debugger
//
//  Created by Martin Cardozo on 12/10/2022.
//

#import "ViewController.h"
#import "LBDebugger.h"

LBDebugger *debugger;

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    debugger = [[LBDebugger alloc] initWithCanvas: self.view];
}

@end
