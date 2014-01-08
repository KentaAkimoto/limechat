//
//  SnapController.h

#import <Cocoa/Cocoa.h>
#import <QTKit/QTkit.h>
#import "Preferences.h"

@interface SnapController : NSObject {
    
    IBOutlet QTCaptureView *mCaptureView;
    
    QTCaptureSession            *mCaptureSession;
    QTCaptureMovieFileOutput    *mCaptureMovieFileOutput;
    QTCaptureDecompressedVideoOutput  *mCaptureDecompressedVideoOutput;
    QTCaptureDeviceInput        *mCaptureVideoDeviceInput;
    QTCaptureDeviceInput        *mCaptureAudioDeviceInput;
    
    CVImageBufferRef mCurrentImageBuffer;
}

@property (readonly,nonatomic) BOOL isRunning;

- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;
- (IBAction)takePicture:(id)sender;

+ (id) sharedInstance;
+ (id)allocWithZone:(NSZone *)zone;

- (void) setup;
- (void) stopRunning;

@end
