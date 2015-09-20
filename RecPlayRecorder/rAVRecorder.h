//
//  rAVRecorder.h
//  Lesestudio
//
//  Created by Ruedi Heimlicher on 17.08.2015.
//  Copyright (c) 2015 Ruedi Heimlicher. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AVCaptureVideoPreviewLayer;
@class AVCaptureSession;
@class AVCaptureDeviceInput;
@class AVCaptureMovieFileOutput;
@class AVCaptureAudioPreviewOutput;
@class AVCaptureConnection;
@class AVCaptureDevice;
@class AVCaptureDeviceFormat;
@class AVFrameRateRange;

@interface rAVRecorder : NSObject <AVCaptureFileOutputDelegate, AVCaptureFileOutputRecordingDelegate>
{
   //NSView                           *previewView;
   AVCaptureVideoPreviewLayer       *previewLayer;
   //NSLevelIndicator                 *audioLevelMeter;
   
   AVCaptureSession                 *session;
   AVCaptureDeviceInput             *videoDeviceInput;
   AVCaptureDeviceInput             *audioDeviceInput;
   AVCaptureMovieFileOutput            *movieFileOutput;
    AVCaptureAudioFileOutput            *audioFileOutput;
   
   AVCaptureAudioPreviewOutput         *audioPreviewOutput;
   
   NSArray                          *videoDevices;
   NSArray                          *audioDevices;
   
   //NSTimer                          *audioLevelTimer;
   
   NSArray                          *observers;
   NSURL *  tempfileURL;
   NSString* tempDirPfad;
   float AufnahmeLevelWert;

   double startzeit;
   int aufnahmezeit;

}

@property (assign) NSWindow *RecorderFenster;
@property (weak) NSURL* tempDirURL;



#pragma mark Device Selection
@property (retain) NSArray *videoDevices;
@property (retain) NSArray *audioDevices;
@property (assign) AVCaptureDevice *selectedVideoDevice;
@property (assign) AVCaptureDevice *selectedAudioDevice;

#pragma mark - Device Properties
@property (assign) AVCaptureDeviceFormat *videoDeviceFormat;
@property (assign) AVCaptureDeviceFormat *audioDeviceFormat;
@property (assign) AVFrameRateRange *frameRateRange;
- (IBAction)lockVideoDeviceForConfiguration:(id)sender;

#pragma mark - Recording
@property (retain) AVCaptureSession *session;
@property (readonly) NSArray *availableSessionPresets;
@property (readonly) BOOL hasRecordingDevice;
@property (assign,getter=isRecording) BOOL recording;

#pragma mark - Preview
@property (assign) IBOutlet NSView *previewView;
@property (assign) float previewVolume;
@property (assign) IBOutlet NSLevelIndicator *audioLevelMeter;
@property (weak) NSNumber* AudioLevel;

#pragma mark - Transport Controls
@property (readonly,getter=isPlaying) BOOL playing;
@property (readonly,getter=isRewinding) BOOL rewinding;
@property (readonly,getter=isFastForwarding) BOOL fastForwarding;

@property NSString*     LeserPfad;
@property  NSString*                   hiddenAufnahmePfad;

// Methods
- (IBAction)stop:(id)sender;
- (void)refreshDevices;
- (void)setTransportMode:(AVCaptureDeviceTransportControlsPlaybackMode)playbackMode speed:(AVCaptureDeviceTransportControlsSpeed)speed forDevice:(AVCaptureDevice *)device;
-(void)clean;
- (float)AufnahmeLevel;
- (void)AufnahmeTimerFunktion:(NSTimer*)derTimer;
- (void)setstartzeit:(double) t;
- (void)trim;
- (void)cut;
- (void)setPlaying:(BOOL)play;
- (void)setURL:(NSURL*)playerURL;
- (void)setRecording:(BOOL)record mitLeserPfad:(NSString*)leserpfad;
@end
