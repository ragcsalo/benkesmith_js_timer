#import "Timer.h"

@implementation Timer

- (void)start:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(fireTimer:)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)fireTimer:(NSTimer*)timer {
    NSString* js = @"benkesmith.plugins.timer.onTick();";
    [self.commandDelegate evalJs:js];
}

- (void)stop:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [timer invalidate];
        timer = nil;
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
