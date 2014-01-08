//
//  SnapController.m

#import "SnapController.h"

@implementation SnapController

static NSMutableDictionary *_instances;

+ (id) sharedInstance {
    __block SnapController *obj;
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
        // do something
    }
    return self;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd]; // init を直接呼ぼうとしたらエラーを発生させる
    return nil;
}

- (void)setup
{
    
// Create the capture session
    
	mCaptureSession = [[QTCaptureSession alloc] init];
    
// Connect inputs and outputs to the session	
    
	BOOL success = NO;
	NSError *error;
	
// Find a video device  
    
//    QTCaptureDevice *videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    QTCaptureDevice *videoDevice = [QTCaptureDevice deviceWithUniqueID:[Preferences cameraDeviceUniqueId]];
    success = [videoDevice open:&error];
    
    
// If a video input device can't be found or opened, try to find and open a muxed input device
    
	if (!success) {
		videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
		success = [videoDevice open:&error];
		
    }
    
    if (!success) {
        videoDevice = nil;
        // Handle error
        
    }
    
    if (videoDevice) {
//Add the video device to the session as a device input
		
		mCaptureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
		success = [mCaptureSession addInput:mCaptureVideoDeviceInput error:&error];
		if (!success) {
			// Handle error
		}
        
// If the video device doesn't also supply audio, add an audio device input to the session
        
        if (![videoDevice hasMediaType:QTMediaTypeSound] && ![videoDevice hasMediaType:QTMediaTypeMuxed]) {
            
            QTCaptureDevice *audioDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
            success = [audioDevice open:&error];
            
            if (!success) {
                audioDevice = nil;
                // Handle error
            }
            
            if (audioDevice) {
                mCaptureAudioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:audioDevice];
                
                success = [mCaptureSession addInput:mCaptureAudioDeviceInput error:&error];
                if (!success) {
                    // Handle error
                }
            }
        }
        
// Create the movie file output and add it to the session
        
        mCaptureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
        success = [mCaptureSession addOutput:mCaptureMovieFileOutput error:&error];
        if (!success) {
            // Handle error
        }
        
        [mCaptureMovieFileOutput setDelegate:self];

// output
        
        mCaptureDecompressedVideoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
        [mCaptureDecompressedVideoOutput setDelegate:self];
        success = [mCaptureSession addOutput:mCaptureDecompressedVideoOutput error:&error];
        if (!success) {
            [[NSAlert alertWithError:error] runModal];
            return;
        }
        

// Set the compression for the audio/video that is recorded to the hard disk.

	NSEnumerator *connectionEnumerator = [[mCaptureMovieFileOutput connections] objectEnumerator];
	QTCaptureConnection *connection;
	
	// iterate over each output connection for the capture session and specify the desired compression
	while ((connection = [connectionEnumerator nextObject])) {
		NSString *mediaType = [connection mediaType];
		QTCompressionOptions *compressionOptions = nil;
		// specify the video compression options
		// (note: a list of other valid compression types can be found in the QTCompressionOptions.h interface file)
		if ([mediaType isEqualToString:QTMediaTypeVideo]) {
			// use H.264
			compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptions240SizeH264Video"];
		// specify the audio compression options
		} else if ([mediaType isEqualToString:QTMediaTypeSound]) {
			// use AAC Audio
			compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsHighQualityAACAudio"];
		}
		
		// set the compression options for the movie file output
		[mCaptureMovieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
	} 

// Associate the capture view in the UI with the session
        
//        [mCaptureView setCaptureSession:mCaptureSession];
        
        [mCaptureSession startRunning];
        
	}
    
}

// Handle window closing notifications for your device input

- (void)stopRunning
{
	
	[mCaptureSession stopRunning];
    
    if ([[mCaptureVideoDeviceInput device] isOpen])
        [[mCaptureVideoDeviceInput device] close];
    
    if ([[mCaptureAudioDeviceInput device] isOpen])
        [[mCaptureAudioDeviceInput device] close];
    
}

// Handle deallocation of memory for your capture objects
/*
- (void)dealloc
{
	[mCaptureSession release];
	[mCaptureVideoDeviceInput release];
    [mCaptureAudioDeviceInput release];
	[mCaptureMovieFileOutput release];
	
	[super dealloc];
}
*/
#pragma mark-

// Add these start and stop recording actions, and specify the output destination for your recorded media. The output is a QuickTime movie.

- (IBAction)startRecording:(id)sender
{
	//[mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:@"/Users/Shared/My Recorded Movie.mov"]];
    _isRunning = YES;
}

- (IBAction)stopRecording:(id)sender
{
	[mCaptureMovieFileOutput recordToOutputFileURL:nil];
    _isRunning = NO;
}

- (IBAction)takePicture:(id)sender {
    CVImageBufferRef imageBuffer;
    
    @synchronized (self) {
        imageBuffer = CVBufferRetain(mCurrentImageBuffer);
        
        if (imageBuffer) {
            NSCIImageRep *imageRep = [NSCIImageRep imageRepWithCIImage:[CIImage imageWithCVImageBuffer:imageBuffer]];
            NSImage *image = [[NSImage alloc] initWithSize:[imageRep size]];
            [image addRepresentation:imageRep];
            CVBufferRelease(imageBuffer);
            
            float height = image.size.height * 0.1;
            float width = image.size.width * 0.1;
            image = [self resizeImage:image width:width height:height];
            NSURL *imagePath = [NSURL fileURLWithPath:@"/Users/Shared/image.tiff"];
            [[image TIFFRepresentation] writeToURL:imagePath atomically:YES];
            //[image release];
            image = nil;
        }

    }
}

- (NSImage *)resizeImage:(NSImage *)sourceImage width:(float)resizeWidth height:(float)resizeHeight {
    
    NSImage *resizedImage = [[NSImage alloc] initWithSize: NSMakeSize(resizeWidth, resizeHeight)];
    
    NSSize   originalSize = [sourceImage size];
    
    [resizedImage lockFocus];
    
    [sourceImage drawInRect: NSMakeRect(0, 0, resizeWidth, resizeHeight) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
    
    [resizedImage unlockFocus];
    
    return resizedImage;
    
}

// Do something with your QuickTime movie at the path you've specified at /Users/Shared/My Recorded Movie.mov"

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
	//[[NSWorkspace sharedWorkspace] openURL:outputFileURL];
}

// delegate for take picture
- (void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection{
    
    CVImageBufferRef imageBufferToRelease;
    
    CVBufferRetain(videoFrame);
    
    @synchronized (self) {
        imageBufferToRelease = mCurrentImageBuffer;
        mCurrentImageBuffer = videoFrame;
    }

    CVBufferRelease(imageBufferToRelease);
    
}

@end
