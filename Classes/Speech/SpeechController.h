//
//  SpeechController.h
//  LimeChat
//
//  Created by Kenta Akimoto on 2014/01/12.
//
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Preferences.h"

@interface SpeechController : NSObject <NSSpeechSynthesizerDelegate>

@property (assign,nonatomic) BOOL running;

+ (id) sharedInstance;
+ (id) allocWithZone:(NSZone *)zone;

- (void)setVoice:(NSString*)voiceId;
- (void)speak:(NSString*)text who:(NSString*)who;

@end
