//
//  GyazoUploader.h
//  LimeChat
//
//  Created by Kenta Akimoto on 2013/12/29.
//
//

#import <Foundation/Foundation.h>

@interface GyazoUploader : NSObject

+ (NSString *) upload:(NSString*) filename;

int callRubyScript(NSString * filename, NSString ** result);

@end
