#import <Cordova/CDV.h>

@interface Timer : CDVPlugin {
    NSTimer *timer;
}

- (void)start:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;

@end
