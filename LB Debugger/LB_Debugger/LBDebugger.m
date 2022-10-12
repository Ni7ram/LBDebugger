/******************************************************************
 Created by Martin Cardozo on 5/9/17.
 Copyright (c) 2017 Litebyte. All rights reserved.
******************************************************************/

// iOS
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// My classes
#import "LBDebugger.h"
#import "PieChart.h"
#import "Tab.h"
#import "Message.h"

/******************************************************************
                            CONSTANTS
******************************************************************/

// FRAME
const int DEFAULT_X               = 20;
const int DEFAULT_Y               = 40;
const int DEFAULT_CORNER_RADIUS   = 5;
const int DEFAULT_CONSOLE_PADDING = 10;

// COLORS
const int DEFAULT_FONT_COLOR[] = { 200, 200, 200 }; //(RGB)
const float DEFAULT_BG_COLOR[] = { 0.0f, 0.0f, 0.0f, 0.8f }; //(RGBA)

// FONT PROPERTIES
const int DEFAULT_FONT_SIZE         = 12;
NSString *const DEFAULT_FONT_FAMILY = @"Courier New";

// TABS
Tab* tabsArray[5];
NSString* DEFAULT_TABS[]         = {@"All", @"Misc.", @"Exec. Time", @"Network", @"Internal"};
UIColor* DEFAULT_TABS_COLORS[5];
const int DEFAULT_TAB_WIDTH      = 82;
const int DEFAULT_TAB_HEIGHT     = 25;
const int DEFAULT_TAB_SEPARATION = 5;
const int DEFAULT_SCROLL_BUTTON_WIDTH = 25;
const int TAB_SCROLL_SPEED = 70;

//FPS
CADisplayLink* FPS;

/******************************************************************
                            INTERFACE
******************************************************************/

#pragma mark - Interface

@interface LBDebugger ()
    // PRIVATE VARS
    @property bool DEV_MODE;
    @property bool logToNSLog;

    @property __weak LBDebugger *weakSelf;

    @property NSLayoutConstraint* debuggerLeftC;
    @property NSLayoutConstraint* debuggerTopC;
    @property NSLayoutConstraint* debuggerHeightC;
    @property NSLayoutConstraint* debuggerWidthC;

    // PRIVATE METHODS
    - (void) createDebugger;
    - (void) createContainer;
    - (void) createConsole;
    - (void) createAccessTab;
    - (void) createTabsSystem;
    - (void) createCustomTabs;
    - (void) scrollTabsToLeft;
    - (void) scrollTabsToRight;
    - (void) addShadow: (UIView*) obj;
    - (void) loadTab: (int) tabID;
    - (void) showPieChart;
    - (void) hidePieChart;
    - (void) repositionPieChart;
    - (Message*) newMessage: (NSString*) _message tab: (int) _tab;
@end

/******************************************************************
                        IMPLEMENTATION
******************************************************************/

@implementation LBDebugger {
    // VISUAL PROPERTIES
    int x;
    int y;
    int width;
    int height;
    UIColor* color;
    
    // GRAPHIC ELEMENTS
    UIView* canvas;
    UIView* vContainer;
    UIButton* accessTab;
    UITextView* console;
    UIView* tabsContainer;
    UIButton* leftTabScrollBtn;
    UIButton* rightTabScrollBtn;
    UILabel* FPSLabel;
    UIView* frame;
    
    PieChart* pieChart;
    
    // OTHER
    bool firstTime;
    int selectedTab;
    NSDate* methodStart;
    
    int activeTab;
    
    NSMutableArray* logArray;
}

/*****************************************************************
                CONSTRUCTORS / INITIALIZERS
*****************************************************************/

#pragma mark - Initializers

- (id) init {
    // TODO: Singleton
    self = [super init];
    
    DEFAULT_TABS_COLORS[0] = [UIColor whiteColor];
    DEFAULT_TABS_COLORS[1] = [UIColor redColor];
    DEFAULT_TABS_COLORS[2] = [UIColor blueColor];
    DEFAULT_TABS_COLORS[3] = [UIColor greenColor];
    DEFAULT_TABS_COLORS[4] = [UIColor grayColor];
    
    return self;
}

// DEFAULT INIT
- (id) initWithCanvas: (UIView*) _canvas {
    self = [self init];
    _weakSelf = self
    
    // SET DEFAULT VALUES
    canvas = _canvas;
    x      = DEFAULT_X;
    y      = DEFAULT_Y;
    width  = (canvas.frame.size.width / 2)  - 20;
    height = canvas.frame.size.height - 120;
    color  = [UIColor colorWithRed: DEFAULT_BG_COLOR[0] green: DEFAULT_BG_COLOR[1] blue: DEFAULT_BG_COLOR[2] alpha: DEFAULT_BG_COLOR[3]];

    // CREATE
    [self createDebugger];
    
    return self;
}

// CUSTOM INIT
- (id) initWithCanvas: (UIView*) _canvas x: (int)_x y: (int)_y width: (int)_width height: (int)_height color: (UIColor*)_color {
    self = [self init];
    
    // COPY CONSTRUCTOR VALUES
    canvas = _canvas;
    x      = _x;
    y      = _y;
    width  = _width;
    height = _height;
    color  = _color;
    
    // CREATE
    [self createDebugger];
    
    return self;
}

/*****************************************************************
                        PRIVATE METHODS
*****************************************************************/

#pragma mark - Debugger creation

- (void) createDebugger {
    // VISUAL ASSETS
    [self createContainer];
    [self createConsole];
    [self createAccessTab];
    [self createTabsSystem];
    [self createPieChart];
    
    // DEVICE ROTATION RESPONSE
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(rotateControls) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    // FPS COUNTER
    FPS = [CADisplayLink displayLinkWithTarget: self selector: @selector(FPSMeasure)];
    [FPS setFrameInterval: 1.0];
    [FPS addToRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
    
    // OTHER VARs INIT
    firstTime = true;
    _logToNSLog = false;
    logArray = [NSMutableArray array];
    activeTab = 0;
    [self loadTab: 0]; // 0 = All
    [self logToConsole:@"[ Debugger initialized.. ]"];
}

- (void) createContainer {
    vContainer = [[UIView alloc] initWithFrame: CGRectMake(DEFAULT_CONSOLE_PADDING, -DEFAULT_CONSOLE_PADDING, 0, 0)];
    vContainer.backgroundColor = color;
    vContainer.layer.cornerRadius = DEFAULT_CORNER_RADIUS;
    vContainer.clipsToBounds = YES;
    
    [canvas addSubview: vContainer];
}

- (void) createConsole {
    // CONSOLE
    console = [[UITextView alloc] init];
    console.textColor = [UIColor colorWithRed: DEFAULT_FONT_COLOR[0] green: DEFAULT_FONT_COLOR[1] blue: DEFAULT_FONT_COLOR[2] alpha: 1.0f];
    console.font = [UIFont fontWithName: DEFAULT_FONT_FAMILY size: DEFAULT_FONT_SIZE];
    console.backgroundColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.4];
    console.editable = false;
    console.selectable = false;
    console.autoresizesSubviews = false;
    console.contentInset = UIEdgeInsetsMake(-14, 0, 0, 0); // Text position inside UITextView
    console.contentSize = CGSizeMake(console.frame.size.height, console.contentSize.height);
    console.showsHorizontalScrollIndicator = NO;
    console.translatesAutoresizingMaskIntoConstraints = NO;
    [console updateConstraintsIfNeeded];
    
    [vContainer addSubview: console];
    
    // FPS LABEL
    FPSLabel = [[UILabel alloc] init];
    FPSLabel.font = [UIFont fontWithName: DEFAULT_FONT_FAMILY size: DEFAULT_FONT_SIZE + 4];
    FPSLabel.textColor = [UIColor colorWithWhite: 255 alpha: 0.5f];
    FPSLabel.backgroundColor = [UIColor clearColor];
    FPSLabel.text = @"";
    FPSLabel.userInteractionEnabled = NO;
    
    [vContainer addSubview: FPSLabel];
}

- (void) createAccessTab {
    accessTab = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    accessTab.frame = CGRectMake(canvas.frame.size.width - 35, 40, 40, 30);
    accessTab.backgroundColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.8];
    accessTab.layer.cornerRadius = DEFAULT_CORNER_RADIUS;
    accessTab.layer.zPosition = MAXFLOAT;
    [accessTab addTarget: self action: @selector(toogle:) forControlEvents: UIControlEventTouchUpInside];

    [canvas addSubview: accessTab];
}

- (void) createTabsSystem {
    // CREATE CONTAINER
    tabsContainer = [[UIView alloc] init];
    tabsContainer.clipsToBounds = YES;
    [vContainer addSubview: tabsContainer];
    
    // CREATE DEFAULT TABS
    int tabsCount = sizeof(DEFAULT_TABS) / sizeof(DEFAULT_TABS[0]);
    for (int i = 0; i < tabsCount; i++) {
        Tab* tmpTab = [[Tab alloc] initWithCanvas: tabsContainer x: i * (DEFAULT_TAB_WIDTH + DEFAULT_TAB_SEPARATION) y: 0 w: DEFAULT_TAB_WIDTH h: DEFAULT_TAB_HEIGHT ID: i color: [UIColor greenColor] title: DEFAULT_TABS[i] actionResponder: self];
        
        tmpTab.tag = i;
        tabsArray[i] = tmpTab;
    }
    
    // CREATE SCROLL BUTTONS
    leftTabScrollBtn  = [[UIButton alloc] initWithFrame: CGRectMake(DEFAULT_CONSOLE_PADDING, DEFAULT_CONSOLE_PADDING, DEFAULT_SCROLL_BUTTON_WIDTH - 5, DEFAULT_TAB_HEIGHT)];
    rightTabScrollBtn = [[UIButton alloc] initWithFrame: CGRectMake(canvas.frame.size.width/2 - DEFAULT_SCROLL_BUTTON_WIDTH - (DEFAULT_CONSOLE_PADDING * 4) + 5 + DEFAULT_CONSOLE_PADDING, DEFAULT_CONSOLE_PADDING, DEFAULT_SCROLL_BUTTON_WIDTH - 5, DEFAULT_TAB_HEIGHT)];
    
    [leftTabScrollBtn setTitle: @"<" forState: UIControlStateNormal];
    [rightTabScrollBtn setTitle: @">" forState: UIControlStateNormal];
    leftTabScrollBtn.layer.cornerRadius  = 5;
    rightTabScrollBtn.layer.cornerRadius = 5;
    leftTabScrollBtn.titleLabel.font  = [UIFont fontWithName: DEFAULT_FONT_FAMILY size: DEFAULT_FONT_SIZE];
    rightTabScrollBtn.titleLabel.font = [UIFont fontWithName: DEFAULT_FONT_FAMILY size: DEFAULT_FONT_SIZE];
    leftTabScrollBtn.titleLabel.textColor  = [UIColor whiteColor];
    rightTabScrollBtn.titleLabel.textColor = [UIColor whiteColor];
    leftTabScrollBtn.backgroundColor  = [[UIColor alloc] initWithRed: 0 green: 0 blue: 0 alpha: 0.5];
    rightTabScrollBtn.backgroundColor = [[UIColor alloc] initWithRed: 0 green: 0 blue: 0 alpha: 0.5];
    leftTabScrollBtn.alpha  = 0;
    rightTabScrollBtn.alpha = 0;
    
    [leftTabScrollBtn  addTarget: self action: @selector(scrollTabsToLeft) forControlEvents: UIControlEventTouchUpInside];
    [rightTabScrollBtn addTarget: self action: @selector(scrollTabsToRight) forControlEvents: UIControlEventTouchUpInside];
    
    [vContainer addSubview: leftTabScrollBtn];
    [vContainer addSubview: rightTabScrollBtn];
    
    // CUSTOMIZED TABS (premium)
    [self createCustomTabs];
}

- (void) createPieChart {
    pieChart = [[PieChart alloc] initWithCanvas: vContainer];
    [self addShadow: pieChart.view];
}

#pragma mark - Other Methods

- (void) loadTab: (int) tabID {
    // AVOID LOADING MULTIPLE TIMES THE SAME TAB
    if (tabID == activeTab) { return; }
    
    // 1. GENERATE TAB FILTERED CONTENT
    NSString* entireTabText = @"";
    
    if (tabID == 0) { // All
        for (Message* msg in logArray) {
            entireTabText = [NSString stringWithFormat: @"%@\r%@", entireTabText, [msg getText]];
        }
    } else {
        for (Message* msg in logArray) {
            if (msg.tab == tabID) {
                entireTabText = [NSString stringWithFormat: @"%@\r%@", entireTabText, [msg getText]];
            }
        }
    }
    
    // 2. IF EXEC. TIME, PIE CHART..
    if (tabID == 2) {
        [self showPieChart];
    } else if (activeTab == 2) {
        [self hidePieChart];
    }
    
    // 3. TURN TABS ON/OFF
    for (int i = 0; i < (sizeof tabsArray) / (sizeof tabsArray[0]); i++) {
        [tabsArray[i] off];
    }
    [tabsArray[tabID] on];
    
    activeTab = tabID;
    
    // 4. CHANGE TEXTVIEW
    console.text = entireTabText;
}


- (void) showPieChart {
    [self repositionPieChart];
    [pieChart show];
    
    // ADAPT CONSOLE HEIGHT
    [UIView animateWithDuration: 0.5 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations:^() {
        CGRect newFrame = self->console.frame;
        newFrame.size.height /= 2;
        self->console.frame = newFrame;
    } completion: ^(BOOL finished) {}];
}

- (void) hidePieChart {
    [pieChart hide];
    
    // ADAPT CONSOLE HEIGHT
    [UIView animateWithDuration: 0.5 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations:^() {
        LBDebugger *strongSelf = self->_weakSelf;
        
        CGRect newFrame = strongSelf->console.frame;
        newFrame.size.height *= 2;
        strongSelf->console.frame = newFrame;
    } completion: ^(BOOL finished) {}];
}

- (void) repositionPieChart {
    [pieChart repositionWithX: 0 y: -50 w: vContainer.frame.size.width h: vContainer.frame.size.height];
}

- (void) FPSMeasure {
    FPSLabel.text = [NSString stringWithFormat:@"%d FPS", (int)(ceil)(1/(float)FPS.duration)];
}

- (void) addShadow: (UIView*) obj {
    obj.clipsToBounds       = NO;
    obj.layer.shadowOffset  = CGSizeMake(3, 2);
    obj.layer.shadowRadius  = 5;
    obj.layer.shadowOpacity = 0.7;
}

- (void) rotateControls {
    LBDebugger *strongSelf = self->_weakSelf;
    
    // Resposition All (animated)
    [UIView animateWithDuration: 0.6 delay: 0.4 options: UIViewAnimationOptionCurveEaseOut animations:^() {
        
        // vContainer
        [strongSelf->vContainer setFrame: CGRectMake(strongSelf->x, strongSelf->y, (strongSelf->canvas.frame.size.width/2) - DEFAULT_CONSOLE_PADDING * 2, (strongSelf->canvas.frame.size.height) - 60)];
        
        // Console
        int h = (strongSelf->activeTab != 2) ? strongSelf->canvas.frame.size.height : (strongSelf->canvas.frame.size.height+130)/2;
        [strongSelf->console setFrame: CGRectMake(strongSelf->x - DEFAULT_CONSOLE_PADDING, strongSelf->y, (strongSelf->canvas.frame.size.width/2) - (DEFAULT_CONSOLE_PADDING * 4), h - 130)];
        
        // TABS (if necessary, create scroll buttons for tabs, and adapt container)
        if (((DEFAULT_TAB_SEPARATION + DEFAULT_TAB_WIDTH) * sizeof(DEFAULT_TABS) / sizeof(DEFAULT_TABS[0])) >= (strongSelf->canvas.frame.size.width/2) - (DEFAULT_CONSOLE_PADDING * 4)) {
            // Scroll necesario
            [strongSelf->tabsContainer setFrame: CGRectMake(strongSelf->x - DEFAULT_CONSOLE_PADDING + DEFAULT_SCROLL_BUTTON_WIDTH, strongSelf->y - 30, ((strongSelf->canvas.frame.size.width/2) - DEFAULT_CONSOLE_PADDING * 4) - 1 - (DEFAULT_SCROLL_BUTTON_WIDTH * 2), DEFAULT_TAB_HEIGHT + 2)];
        } else {
            // Scroll innecesario
            [strongSelf->tabsContainer setFrame: CGRectMake(strongSelf->x - DEFAULT_CONSOLE_PADDING, strongSelf->y - 30, ((strongSelf->canvas.frame.size.width/2) - DEFAULT_CONSOLE_PADDING * 4) - 1, DEFAULT_TAB_HEIGHT + 2)];
            
            // REPOSITION TABS IF THEY ARE SCROLLED
            for (int i = 0; i < (sizeof tabsArray) / (sizeof tabsArray[0]); i++) {
                CGRect newPos = tabsArray[i].btn.frame;
                newPos.origin.x = i * (DEFAULT_TAB_WIDTH + DEFAULT_TAB_SEPARATION);
                [UIView animateWithDuration: 0.2 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations:^() {
                    [tabsArray[i].btn setFrame: newPos];
                } completion: ^(BOOL finished) {} ];
            }
        }
        
        // TABS RIGHT SCROLL BUTTON
        [strongSelf->rightTabScrollBtn setFrame: CGRectMake(strongSelf->canvas.frame.size.width/2 - DEFAULT_SCROLL_BUTTON_WIDTH - (DEFAULT_CONSOLE_PADDING * 4) + 5 + DEFAULT_CONSOLE_PADDING, DEFAULT_CONSOLE_PADDING, DEFAULT_SCROLL_BUTTON_WIDTH - 5, DEFAULT_TAB_HEIGHT)];
        
        // FPS
        [strongSelf->FPSLabel setFrame: CGRectMake(strongSelf->vContainer.frame.size.width - 75, strongSelf->vContainer.frame.size.height - 30, 100, 30)];
    } completion: ^(BOOL finished) {
        strongSelf->console.text = [NSString stringWithFormat: @"%@ ", strongSelf->console.text]; // Solves bug (clipped textView after rotating)
    }];
    
    // SHOW / HIDE SCROLL TABS BUTTONS (queda mal en el bloque de la animacion)
    if (((DEFAULT_TAB_SEPARATION + DEFAULT_TAB_WIDTH) * sizeof(DEFAULT_TABS) / sizeof(DEFAULT_TABS[0])) >= (canvas.frame.size.width/2) - (DEFAULT_CONSOLE_PADDING * 4)) {
        leftTabScrollBtn.alpha  = 1;
        rightTabScrollBtn.alpha = 1;
    } else {
        leftTabScrollBtn.alpha  = 0;
        rightTabScrollBtn.alpha = 0;
    }
    
    // Access tab
    [accessTab setFrame: CGRectMake(canvas.frame.size.width + 30, 40, 40, 70)];
    accessTab.alpha = 0;
    
    [UIView animateWithDuration: 0.9 delay: 1 options: UIViewAnimationOptionCurveEaseOut animations:^() {
        [strongSelf->accessTab setFrame: CGRectMake(strongSelf->canvas.frame.size.width - 30, 40, 40, 70)];
        strongSelf->accessTab.alpha = 1;
    } completion: ^(BOOL finished) {} ];
    
    // PieChart
    [self repositionPieChart];
}

- (void) scrollTabsToLeft {
    int tabsCount = (sizeof tabsArray) / (sizeof tabsArray[0]);
    int scrollAmount;
    
    // CHECK IF SHOULD KEEP SCROLLING, AND HOW MUCH (pixel perfect scrolling)
    if (tabsArray[0].btn.frame.origin.x < 0) {
        if (-(tabsArray[0].btn.frame.origin.x) < TAB_SCROLL_SPEED) {
            scrollAmount = -(tabsArray[0].btn.frame.origin.x);
        } else {
            scrollAmount = TAB_SCROLL_SPEED;
        }
        
        // MOVE ALL BUTTONS
        for (int i = 0; i < tabsCount; i++) {
            CGRect newPos = tabsArray[i].btn.frame;
            newPos.origin.x += scrollAmount;
            
            // TRIGGER ANIMATION
            [UIView animateWithDuration: 0.2 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations:^() {
                [tabsArray[i].btn setFrame: newPos];
            } completion: ^(BOOL finished) {} ];
        }
    }
}

- (void) scrollTabsToRight {
    int tabsCount     = (sizeof tabsArray) / (sizeof tabsArray[0]);
    int lastTabBorder = tabsArray[tabsCount - 1].btn.frame.origin.x + tabsArray[tabsCount - 1].btn.frame.size.width;
    int scrollAmount;
    
    // CHECK IF SHOULD KEEP SCROLLING, AND HOW MUCH (pixel perfect scrolling)
    if (lastTabBorder > vContainer.frame.size.width - DEFAULT_SCROLL_BUTTON_WIDTH) {
        if (lastTabBorder - vContainer.frame.size.width - DEFAULT_CONSOLE_PADDING - DEFAULT_SCROLL_BUTTON_WIDTH < TAB_SCROLL_SPEED) {
            scrollAmount = lastTabBorder - vContainer.frame.size.width - DEFAULT_CONSOLE_PADDING - DEFAULT_SCROLL_BUTTON_WIDTH;
        } else {
            scrollAmount = TAB_SCROLL_SPEED;
        }
        
        for (int i = 0; i < (sizeof tabsArray) / (sizeof tabsArray[0]); i++) {
            CGRect newPos = tabsArray[i].btn.frame;
            newPos.origin.x -= TAB_SCROLL_SPEED;
            
            // TRIGGER ANIMATION
            [UIView animateWithDuration: 0.2 delay: 0 options: UIViewAnimationOptionCurveEaseOut animations:^() {
               [tabsArray[i].btn setFrame: newPos];
            } completion: ^(BOOL finished) {} ];
        }
    }
}

// MESSAGES FACTORY
- (Message*) newMessage: (NSString*) _message tab: (int) _tab {
    Message* message = [[Message alloc] initWithMessage: _message tab: _tab];
    return message;
}

/*****************************************************************
                        DEBUGGER API
*****************************************************************/

#pragma mark - API

- (void) toogle: (UIButton*) sender {
    float delay = (firstTime) ? 0.0f : 0.2f;
    firstTime = false;
    
    // FADE IN/OUT ANIMATION
    [UIView animateWithDuration: 0.1 delay: delay options: UIViewAnimationOptionCurveEaseOut animations:^() {
        vContainer.alpha = (vContainer.alpha == 0) ? 1 : 0;
    } completion: ^(BOOL finished) {}];
    
    vContainer.layer.zPosition = MAXFLOAT;
}

- (void) logToConsole: (NSString*) text {
    [self logToConsole: text tab: 1]; // 1 = Misc.
}

- (void) logToConsole: (NSString*) text tab: (int) tabID {
    // CLEAN CONSOLE IF FULL
    int lines = (int)console.contentSize.height / console.font.lineHeight;
    int maxNumberOfLines = ((int)console.frame.size.height / console.font.lineHeight) + 1;
    if (lines > maxNumberOfLines) { console.text = @""; }
    
    // LOG
    [logArray addObject: [self newMessage: text tab: tabID]];
    
    if (tabID == activeTab || activeTab == 0) {
        NSString* entireText = [NSString stringWithFormat: @"%@\r%@", console.text, text];
        // NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString: entireText];
        // [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,50)];
        console.text = entireText;
    }
    
    if (_logToNSLog) { NSLog(@"[LB_Debugger: [%@]", text); }
}

- (void) startMeasure {
    methodStart = [NSDate date];
}

- (void) measure: (NSString*) codeID {
    [self logToConsole:[NSString stringWithFormat:@"[ExecTime] %@: %f s", codeID, -[methodStart timeIntervalSinceNow]] tab: 2]; // 2 = Exec. Time
}

- (void) setDevMode: (bool) value {
    _DEV_MODE = value;
}

/*****************************************************************
                    POTENTIAL PREMIUM CONTENT
*****************************************************************/

#pragma mark - Premium Content

- (void) imageInfo: (UIImage*) image {
    NSData* imgData = UIImageJPEGRepresentation(image, 1);
    [self logToConsole: [NSString stringWithFormat: @"[Image info] %0.2f mb (%dx%d)",  (float)[imgData length]/1024/1024,  (int)image.size.width, (int)image.size.height]];
}

- (void) imagePath: (UIImage*) image { // Esto quizas no tiene sentido por el funcionamiento de la API de iOS
    // TODO: [self logToConsole: path];
}

- (void) createCustomTabs {
    // TODO: Custom Tabs
    int tabsCount = sizeof(DEFAULT_TABS) / sizeof(DEFAULT_TABS[0]);
    for (int i = 0; i < tabsCount; i++) {
        // totalTabs += tab;
    }
}

@end
