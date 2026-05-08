#import <UIKit/UIKit.h>

void disableIdleTimer()
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
