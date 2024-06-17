#import "Timer.h"

@implementation Timer

- (void)start:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        self->timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(fireTimer:)
                                                     userInfo:nil
                                                      repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self->timer forMode:NSRunLoopCommonModes];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)fireTimer:(NSTimer*)timer {
    // Ensure this runs on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* js = @"benkesmith.plugins.timer.onTick();";
        [self.commandDelegate evalJs:js];
    });
}

- (void)stop:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [self->timer invalidate];
        self->timer = nil;
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
