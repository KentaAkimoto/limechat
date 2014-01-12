//
//  SpeechController.m
//  LimeChat
//
//  Created by Kenta Akimoto on 2014/01/12.
//
//

#import "SpeechController.h"

@implementation SpeechController{
    NSSpeechSynthesizer *synth;
}

static NSMutableDictionary *_instances;

+ (id) sharedInstance {
    __block SpeechController *obj;
    @synchronized(self) {
        if ([_instances objectForKey:NSStringFromClass(self)] == nil) {
            obj = [[self alloc] initSharedInstance];
        }
    }
    obj = [_instances objectForKey:NSStringFromClass(self)];
    return obj;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if ([_instances objectForKey:NSStringFromClass(self)] == nil) {
            id instance = [super allocWithZone:zone];
            if (_instances == nil) {
                _instances = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            [_instances setObject:instance forKey:NSStringFromClass(self)];
            return instance;
        }
    }
    return nil;
}
- (id)initSharedInstance {
    self = [super init];
    if (self) {
        synth = [[NSSpeechSynthesizer alloc] init]; //start with default voice
        //synth is an ivar
        [synth setDelegate:self];
        NSString *defaultVoiceId = nil;
        if ([Preferences speechVoiceId] != nil) {
            defaultVoiceId = [Preferences speechVoiceId];
        } else {
            defaultVoiceId = [[NSSpeechSynthesizer availableVoices] objectAtIndex:0];
        }
        [synth setVoice:defaultVoiceId];
    }
    return self;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd]; // init を直接呼ぼうとしたらエラーを発生させる
    return nil;
}

-(void)setVoice:(NSString *)voiceId{
    [synth setVoice:voiceId];
}

- (void)speak:(NSString*)text who:(NSString*)who
{
    if (!_running) {
        return;
    }
    NSString *source = [self extractCantSpeakValue:[NSString stringWithFormat:@"%@ say %@",who,text]];
    source = [self convertTextToRomaji:source];
    [synth startSpeakingString:source];
}

- (NSString*) extractCantSpeakValue:(NSString*)source{
    
    NSString *pattern = @"(https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+)";
    NSString *replacement = @"";
    
    NSRegularExpression *regexp = [NSRegularExpression
                                   regularExpressionWithPattern:pattern
                                   options:NSRegularExpressionCaseInsensitive
                                   error:nil
                                   ];
    
    NSString *str = [regexp
                     stringByReplacingMatchesInString:source
                     options:NSMatchingReportProgress
                     range:NSMakeRange(0, source.length)
                     withTemplate:replacement
                     ];
    NSLog(@"%@",  str);
    return str;
}

- (NSString*) convertTextToRomaji:(NSString*)source{
    
    // 日本語のvoiceを選択している場合
    if ([synth.voice rangeOfString:@"kyoko"].location != NSNotFound
        || [synth.voice rangeOfString:@"otoya"].location != NSNotFound) {
        return source;
    }
    NSMutableString* string =[[NSMutableString alloc] initWithString:source];
    // 日本語文字をローマ字に変換する
    CFStringTransform((CFMutableStringRef)string, NULL, kCFStringTransformToLatin, false);
    return string;
}

@end
