CONTENT INDEX:

1. Installation
2. Basic Usage
3. Short example
4. Recommended practices

Advanced usage:

5. Performance Analysis
6. Tab usage

**********************************************************************
			1. INSTALLATION
**********************************************************************


1. Copy the LB_Debugger folder on your XCode project src folder.
2. Paste this three lines on your main controller

———————————————————————————————————————————————————————————
#import "LBDebugger.h"
LBDebugger *debugger;
debugger = [[LBDebugger alloc] initWithCanvas: self.view];
———————————————————————————————————————————————————————————

That’s it!

**********************************************************************
			 2. BASIC USAGE
**********************************************************************


This is a list of all available basic methods:

- initWithCanvas: (UIView*): This is the default initializer, creates a
default debugger. Fixed size, fixed color. The only parameter needed is the
(UIView*) where the debugger is going to be rendered. By default, it should be the
view of the controller in which it is created (see Short Example).

- initWithCanvas: (UIView*) x:(int) y:(int) size:(int) color(UIColor*): Customized
initializer, you have to specify coordinates, size and color.

- logToConsole: (NSString) : Prints text on the debugger.

- setDevMode: (bool): By default is set to true. When set to true an access tab
appears on the upper-right corner. Besides the show/hide functionality, we decided
to put a visual element on the screen so you can be aware that the console is
working (even if you don't see it, after toogling maybe) to avoid releasing an
application with the console accesible and probably showing sensitive information
about your app.


**********************************************************************
		 	3. SHORT EXAMPLE
**********************************************************************

#import "LBDebugger.h"

- (void) viewDidLoad {
    [super viewDidLoad];
    LBDebugger* debugger = [[LBDebugger alloc] initWithCanvas: self.view];
    [debugger logToConsole: @"Test log"];

    [self testMethod];
}

- (void) testMethod {

    // code...

    [debugger startMeasure];

    // HEAVY TASK
    for(int i; i < 10000000; i++) {
        int j = 10000 * i;
    }

    [debugger measure: @"testMethod FOR"];

    // more code...
}
----------------------------------------------------------------------

The output should be something like:
----------------------------------------
[ Debugger Initialized.. ]
Test log
[ExecTime] testMethod FOR: 0.000345 s
----------------------------------------

**********************************************************************
                4. RECOMMENDED PRACTICES
**********************************************************************

In order to mantain the debugger in it's least intrusive form along your
projects, we provide a method to turn it off completely. This way you don't
have to worry about any trace of the debugger in your code, even when
releasing an app. In that case, just put:

[debugger setDevMode: false]

right after creating it, and forget of all the debugger-code related! No
need to remove it, no side effects ;)

**********************************************************************
                5. PERFORMANCE ANALYSIS
**********************************************************************


With LB_Debugger, it only takes two lines of code to measure the execution
speed of a function, client-server communication, algorithm or block of code.
First, you tell the debugger you want to start a new measure, by calling:

[debugger startMeasure];

Second, you tell the debugger to show it in the GUI, along with a custom
text for measure identification, by using:

[debugger measure: (NSString*) ];