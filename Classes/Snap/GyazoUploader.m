//
//  GyazoUploader.m
//  LimeChat
//
//  Created by Kenta Akimoto on 2013/12/29.
//
//

#import "GyazoUploader.h"

@implementation GyazoUploader

+ (NSString *) upload:(NSString*) filename{
    NSString * outputStr = nil;
    [self upload:filename result:&outputStr];
    
    NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:@"http://gyazo.com/(.*)" options:0 error:nil];
    NSArray *matches = [reg matchesInString:outputStr options:0 range:NSMakeRange(0, [outputStr length])];
    NSTextCheckingResult *result = matches[0];
    NSRange r = [result rangeAtIndex:0]; // グループ参照1
    return [NSString stringWithFormat:@"%@.png",[outputStr substringWithRange:r]];
}

+ (void) upload:(NSString*) filename result:(NSString **) result{
    callRubyScript(filename,result);
}

int callRubyScript(NSString * filename, NSString ** result) {
    
    // Call Ruby script
    NSTask *             task = [ [ NSTask alloc ] init ];
    NSPipe *             pipe = [[NSPipe alloc] init];
    NSPipe *          pipeErr = [ NSPipe pipe ];
    NSMutableString* curPath  = [ NSMutableString string ];
    NSMutableString* scrPath  = [ NSMutableString string ];

    // Set pipe
    [task setStandardOutput:pipe];
    
    // Set error pipe
    [ task setStandardError : pipeErr ];
    
    // Get path
    [ curPath setString : [ [ NSBundle mainBundle ] bundlePath ] ];
    [ curPath setString : [ curPath stringByDeletingLastPathComponent ] ];
    
    [ scrPath setString    : [ [ NSBundle mainBundle ] bundlePath ] ];
    [ scrPath appendString : @"/Contents/Resources/script" ];
    
    
    // Execute
    [ task setLaunchPath           : @"/usr/bin/ruby" ];
    [ task setCurrentDirectoryPath : curPath ];
    if (filename == nil){
        [ task setArguments:[NSArray arrayWithObjects:scrPath,scrPath,nil ] ];
    }else{
        [ task setArguments:[NSArray arrayWithObjects:scrPath,scrPath,filename,nil ] ];
    }
    [ task launch ];
//    [ task waitUntilExit ];
    
    NSFileHandle *handle = [pipe fileHandleForReading];
    NSData *data = [handle  readDataToEndOfFile];
    *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(string);
    
    { // Read from pipe
        
        NSData*   dataErr = [ [ pipeErr fileHandleForReading ] availableData ];
        NSString* strErr  = [ NSString stringWithFormat : @"%s", [ dataErr bytes ] ];
        NSLog( @"%@",strErr );
        
    }
    return( [ task terminationStatus ] );
}

@end
