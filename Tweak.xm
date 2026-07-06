#import <UIKit/UIKit.h>

static UIWindow *miniDockWindow = nil;

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;

    // Wait 3 seconds for SpringBoard to settle before injecting the overlay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        // Ensure we don't create multiple windows if the method fires again
        if (miniDockWindow) return;

        CGRect screenBounds = [UIScreen mainScreen].bounds;
        
        // Define the 10% sidebar frame
        // Width is 10% of the screen width
        CGFloat dockWidth = screenBounds.size.width * 0.10;
        CGRect dockFrame = CGRectMake(0, 0, dockWidth, screenBounds.size.height);

        miniDockWindow = [[UIWindow alloc] initWithFrame:dockFrame];
        miniDockWindow.windowLevel = UIWindowLevelStatusBar + 100;
        miniDockWindow.hidden = NO;
        miniDockWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6]; // Semi-transparent black
        
        // Keep this NO for now so you can still click apps behind the dock
        miniDockWindow.userInteractionEnabled = NO; 
        
        // Add a label just to prove it's working
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, dockWidth, 50)];
        label.text = @"Dock";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [miniDockWindow addSubview:label];
    });
}

%end
