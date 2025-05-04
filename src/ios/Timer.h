#import <Cordova/CDV.h>

@interface Timer : CDVPlugin {
    NSTimer *timer;
    NSTimer *stopTimer;
    double   mInterval;
    double   mMaxRuntime;
    BOOL     isRunning;
}

- (void)start:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;

@end
