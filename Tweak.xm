#import <UIKit/UIKit.h>

// Silence compiler warnings about deprecated UI methods
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

// --- ZETSU BRIDGE ---
@interface ZetsuWindow : UIWindow
@end

// The internal function from your class-dump
extern void _Z10CardShrinkP11ZetsuWindowb(ZetsuWindow *window, bool shrink);

// --- DOCK UI ---
@interface PassThroughWindow : UIWindow
@end

@implementation PassThroughWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && CGRectContainsPoint(subview.frame, point)) return YES;
    }
    return NO;
}
@end

static PassThroughWindow *miniDockWindow = nil;
static BOOL isDockHidden = NO;

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGRect screen = [UIScreen mainScreen].bounds;
        
        miniDockWindow = [[PassThroughWindow alloc] initWithFrame:CGRectMake(0, 0, 80, screen.size.height)];
        miniDockWindow.windowLevel = UIWindowLevelAlert + 1;
        miniDockWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        miniDockWindow.hidden = NO;
        miniDockWindow.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(10, 100, 60, 60);
        [btn setTitle:@"Launch" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(launchInZetsu) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:btn];

        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        hideBtn.frame = CGRectMake(10, 200, 60, 30);
        [hideBtn setTitle:@"Min" forState:UIControlStateNormal];
        [hideBtn addTarget:self action:@selector(minimizeActiveZetsuWindow) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:hideBtn];
    });
}

%new
-(void)launchInZetsu {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"] options:@{} completionHandler:nil];
}

%new
-(void)minimizeActiveZetsuWindow {
    // Use performSelector to bypass compiler deprecation checks
    NSArray *allWindows = [[UIApplication sharedApplication] performSelector:@selector(windows)];
    for (UIWindow *window in allWindows) {
        if ([window isKindOfClass:NSClassFromString(@"ZetsuWindow")]) {
            _Z10CardShrinkP11ZetsuWindowb((ZetsuWindow *)window, YES); 
            break;
        }
    }
}

%end
