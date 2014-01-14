//
//  AvatarCollector.m
//  LimeChat
//
//  Created by Kenta Akimoto on 2014/01/11.
//
//

#import "AvatarCollector.h"

@implementation AvatarCollector{
    NSMutableArray *_targetUsers;
}


static NSMutableDictionary *_instances;

+ (id) sharedInstance {
    __block AvatarCollector *obj;
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
        _targetUsers = [@[] mutableCopy];
    }
    return self;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd]; // init を直接呼ぼうとしたらエラーを発生させる
    return nil;
}

- (BOOL)isRunning{
    if ([_targetUsers count] == 0) {
        return NO;
    }
    return YES;
}

- (void) collect:(IRCClient *) client channel:(IRCChannel *) channel{
    
    if ([self isRunning]) {
        return;
    }
    
    [client printLogToConsole:[NSString stringWithFormat:@"AvatarCollector:対象チャンネル：%@ (see /Users/Shared/limeChat/whois_history.log)",channel.name] timestamp:[NSDate date].timeIntervalSince1970];
    
    [_targetUsers removeAllObjects];
    for (IRCUser* member in channel.members) {
        [_targetUsers addObject:member.nick];
    }
    
    for (IRCUser* member in channel.members) {
        
        // 少し間隔を開けて実行する
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            client.silentWhoisMode = YES; // whoisダイアログが表示されないようにフラグを立てる
            client.delegateSilentWhois = self;
            [client sendWhois:member.nick];
            //[u sendCommand:@"whois kenta" completeTarget:YES target:@"#test"];
            
        });
    }
}

-(void) IRCClientSilentWhois:(id)sender getNick:(NSString *)nick realName:(NSString *)realName userName:(NSString *)userName address:(NSString *)address{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        NSDate* date = [NSDate date];
        NSString* dateStr = [formatter stringFromDate:date];
        NSLog(@"%@ %@ %@",dateStr,nick,realName);
        
        NSString *avatarImgDir = @"/Users/Shared/limeChat";
        [self writeLog:avatarImgDir log:[NSString stringWithFormat:@"%@ %@ %@\n",dateStr,nick,realName]];

        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // フォルダが存在しなければ作成する
        BOOL isDirectory;
        BOOL isExists = [fileManager fileExistsAtPath:avatarImgDir isDirectory:&isDirectory];
        if (!isExists) {
            [fileManager createDirectoryAtPath:avatarImgDir withIntermediateDirectories:YES attributes:nil error:&error];
        }
        // バッチ実行
        NSString *command = [NSString stringWithFormat:@"cd /Users/Shared/limeChat; ./get_avatar.sh %@ %@",realName,nick];
        NSString *commandResponse = [self execScript:command];
        
        [_targetUsers removeObject:nick];
        
        IRCClient *client = sender;
        [client printLogToConsole:[NSString stringWithFormat:@"AvatarCollector:%@",commandResponse] timestamp:[NSDate date].timeIntervalSince1970];
        
        // 全てのリクエストを処理したら、whoisダイアログが表示されるようにフラグを落とす
        if (![self isRunning]) {
            client.silentWhoisMode = NO; // whoisダイアログが表示されるように戻す
        }

    });
}

- (NSString *)execScript:(NSString *)command
{
    NSTask *task = [[NSTask alloc] init];
    
    // 標準出力用
    NSPipe *outPipe = [NSPipe pipe];
    [task setStandardOutput:outPipe];
    
    // 標準エラー用
    // 標準出力用と同じNSPipeをsetしても良いけど、分けておくと結果がエラーになったかどうかが分かる。
    NSPipe *errPipe = [NSPipe pipe];
    [task setStandardError:errPipe];
    
    [task setLaunchPath: @"/bin/sh"];
    //[task setArguments: [NSArray arrayWithObjects: @"-c", @"cd ~/tmp; git add .; git commit -m 'Commit from NSTask'; git log > log.txt", nil]];
    [task setArguments: [NSArray arrayWithObjects: @"-c", command, nil]];
    
    // ここでコマンドの実行
    // コマンドが終了するのを待たずに、すぐに処理が返ってくる
    [task launch];
    
    // コマンドの結果を取得
    // readDataToEndOfFile によって、実行が終了するまで待ってくれる。
    // コマンドの実行結果に応じて、標準出力と標準エラーのどちらかにデータが入っている。
    NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
    if (data != nil && [data length])
    {
        NSString *strOut = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", strOut);
        return strOut;
    }
    
    data = [[errPipe fileHandleForReading] readDataToEndOfFile];
    if (data != nil && [data length])
    {
        NSString *strErr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"ERROR:%@", strErr);
        return strErr;
    }
    return @"";
}

- (void) writeLog:(NSString*)path log:(NSString*)log{
    
    NSString *filePath = [path stringByAppendingPathComponent:@"whois_history.log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        BOOL result = [fileManager createFileAtPath:filePath
                                           contents:[NSData data] attributes:nil];
        if (!result) {
            return;
        }
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!fileHandle) {
        return;
    }
    
    NSData *data = [NSData dataWithBytes:log.UTF8String
                                   length:[log lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle synchronizeFile];
    [fileHandle closeFile];
}

@end
