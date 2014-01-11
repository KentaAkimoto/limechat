//
//  AvatarCollector.h
//  LimeChat
//
//  Created by Kenta Akimoto on 2014/01/11.
//
//

#import <Foundation/Foundation.h>
#import "IRCClient.h"
#import "IRCChannel.h"

@interface AvatarCollector : NSObject <IRCClientSilentWhoisDelegate>

- (void) collect:(IRCClient *) client channel:(IRCChannel *) channel;

@end
