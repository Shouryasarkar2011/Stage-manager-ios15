#import <UIKit/UIKit.h>

// This is your floating Stage Pane window
@interface StageManagerWindow : UIWindow
@end

@implementation StageManagerWindow
- (instancetype)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 100;
        self.hidden = NO;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2]; // Semi-transparent for now
        self.userInteractionEnabled = YES;
    }
    return self;
}
@end

// Global variable to keep the window alive
static StageManagerWindow *stageWindow;

%ctor {
    // Initialize the window when SpringBoard starts
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        stageWindow = [[StageManagerWindow alloc] init];
        NSLog(@"[StageManager] Stage Pane Initialized");
    });
}

// Hooking Zetsu's notification to trigger your UI
%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    
    // Listen for the Zetsu signal we talked about
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ZetsuMinimized" 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
        
        NSLog(@"[StageManager] Detected minimize! Updating UI...");
        // Here is where you add your logic to update the UIStackView inside stageWindow
    }];
}

%end