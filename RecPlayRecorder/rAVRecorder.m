//
//  rAVRecorder.m
//  Lesestudio
//
//  Created by Ruedi Heimlicher on 17.08.2015.
//  Copyright (c) 2015 Ruedi Heimlicher. All rights reserved.
//

#import "rAVRecorder.h"
#import <Cocoa/Cocoa.h>
#include <unistd.h>

@interface rAVRecorder () <AVCaptureFileOutputDelegate, AVCaptureFileOutputRecordingDelegate>

// Properties for internal use
@property (retain) AVCaptureDeviceInput *videoDeviceInput;
@property (retain) AVCaptureDeviceInput *audioDeviceInput;
@property (readonly) BOOL selectedVideoDeviceProvidesAudio;
@property (retain) AVCaptureAudioPreviewOutput *audioPreviewOutput;
@property (retain) AVCaptureMovieFileOutput *movieFileOutput;
@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (assign) NSTimer *audioLevelTimer;
@property (retain) NSArray *observers;

// Methods for internal use
- (void)refreshDevices;
- (void)setTransportMode:(AVCaptureDeviceTransportControlsPlaybackMode)playbackMode speed:(AVCaptureDeviceTransportControlsSpeed)speed forDevice:(AVCaptureDevice *)device;

@end

@implementation rAVRecorder

@synthesize videoDeviceInput;
@synthesize audioDeviceInput;
@synthesize videoDevices;
@synthesize audioDevices;
@synthesize session;
@synthesize audioLevelMeter;
@synthesize audioPreviewOutput;
@synthesize movieFileOutput;
@synthesize previewView;
@synthesize previewLayer;
@synthesize audioLevelTimer;
@synthesize observers;
@synthesize RecorderFenster;

@synthesize LeserPfad;

- (void)setstartzeit:(double) t
{
   startzeit = t;
}

- (id)init
{
   self = [super init];
   if (self) {
      // Create a capture session
      session = [[AVCaptureSession alloc] init];
      
      // Attach preview to session
      CALayer *previewViewLayer = [[self previewView] layer];
      [previewViewLayer setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
      AVCaptureVideoPreviewLayer *newPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[self session]];
      [newPreviewLayer setFrame:[previewViewLayer bounds]];
      [newPreviewLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
      [previewViewLayer addSublayer:newPreviewLayer];
      [self setPreviewLayer:newPreviewLayer];
      
      // Start the session
      [[self session] startRunning];
      
      // Start updating the audio level meter
      [self setAudioLevelTimer:[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateAudioLevels:) userInfo:nil repeats:YES]];


      // Capture Notification Observers
      NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
      id runtimeErrorObserver = [notificationCenter addObserverForName:AVCaptureSessionRuntimeErrorNotification
                                                                object:session
                                                                 queue:[NSOperationQueue mainQueue]
                                                            usingBlock:^(NSNotification *note) {
                                                               dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                                  NSLog(@"AVCaptureSessionRuntimeErrorNotification");
                                                                 // [[[self view] window] presentError:[[note userInfo] objectForKey:AVCaptureSessionErrorKey]];
                                                               });
                                                            }];
      id didStartRunningObserver = [notificationCenter addObserverForName:AVCaptureSessionDidStartRunningNotification
                                                                   object:session
                                                                    queue:[NSOperationQueue mainQueue]
                                                               usingBlock:^(NSNotification *note)
                                    {
                                       NSLog(@"did start running");
                                    }];
      id didStopRunningObserver = [notificationCenter addObserverForName:AVCaptureSessionDidStopRunningNotification
                                                                  object:session
                                                                   queue:[NSOperationQueue mainQueue]
                                                              usingBlock:^(NSNotification *note) {
                                                                 NSLog(@"did stop running");
                                                              }];
      id deviceWasConnectedObserver = [notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification
                                                                      object:nil
                                                                       queue:[NSOperationQueue mainQueue]
                                                                  usingBlock:^(NSNotification *note) {
                                                                     [self refreshDevices];
                                                                  }];
      id deviceWasDisconnectedObserver = [notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification
                                                                         object:nil
                                                                          queue:[NSOperationQueue mainQueue]
                                                                     usingBlock:^(NSNotification *note) {
                                                                        [self refreshDevices];
                                                                     }];
      observers = [[NSArray alloc] initWithObjects:runtimeErrorObserver, didStartRunningObserver, didStopRunningObserver, deviceWasConnectedObserver, deviceWasDisconnectedObserver, nil];
      
      // Attach outputs to session
      movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
      [movieFileOutput setDelegate:self];
      [session addOutput:movieFileOutput];
      
      audioPreviewOutput = [[AVCaptureAudioPreviewOutput alloc] init];
      [audioPreviewOutput setVolume:0.f];
      [session addOutput:audioPreviewOutput];
      
      // Select devices if any exist
      AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
      if (videoDevice)
      {
         //NSLog(@"videoDevice yes");
         [self setSelectedVideoDevice:videoDevice];
         [self setSelectedAudioDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio]];
      }
      else
      {
         NSLog(@"videoDevice no");
         [self setSelectedVideoDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeMuxed]];
      }
      //NSLog(@"transportControlsSupported: %d",[[self selectedAudioDevice] transportControlsSupported]);
      // Initial refresh of device list
      [self refreshDevices];
      
   }
   return self;
}


- (BOOL)setDevice
{
   BOOL erfolg = NO;
   AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
   if (audioDevice)
   {
      NSLog(@"audiodevice da");
      erfolg = TRUE;
      [self setSelectedAudioDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio]];
   }
   return erfolg;
}


- (void)didPresentErrorWithRecovery:(BOOL)didRecover contextInfo:(void  *)contextInfo
{
   NSLog(@"didPresentErrorWithRecovery");// Do nothing
}

#pragma mark - Device selection
- (void)refreshDevices
{
   [self setVideoDevices:[[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] arrayByAddingObjectsFromArray:[AVCaptureDevice devicesWithMediaType:AVMediaTypeMuxed]]];
   [self setAudioDevices:[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio]];
   
   [[self session] beginConfiguration];
   //NSLog(@"refreshDevices selectedVideoDevice: %@",[[self selectedVideoDevice]description]);
   if (![[self videoDevices] containsObject:[self selectedVideoDevice]])
      [self setSelectedVideoDevice:nil];
   
   if (![[self audioDevices] containsObject:[self selectedAudioDevice]])
      [self setSelectedAudioDevice:nil];
   
   [[self session] commitConfiguration];
}

- (AVCaptureDevice *)selectedVideoDevice
{
   return nil;
   //return [videoDeviceInput device];
}

- (void)setSelectedVideoDevice:(AVCaptureDevice *)selectedVideoDevice
{
   
   [[self session] beginConfiguration];
   
   if ([self videoDeviceInput]) {
      // Remove the old device input from the session
      [session removeInput:[self videoDeviceInput]];
      [self setVideoDeviceInput:nil];
   }
   
   if (selectedVideoDevice)
   {
      NSError *error = nil;
      
      // Create a device input for the device and add it to the session
      AVCaptureDeviceInput *newVideoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:selectedVideoDevice error:&error];
      if (newVideoDeviceInput == nil) {
         dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSLog(@"newVideoDeviceInput nil");
         });
      } else {
         if (![selectedVideoDevice supportsAVCaptureSessionPreset:[session sessionPreset]])
            [[self session] setSessionPreset:AVCaptureSessionPresetMedium];
         
         [[self session] addInput:newVideoDeviceInput];
         [self setVideoDeviceInput:newVideoDeviceInput];
      }
   }
   [[self session] setSessionPreset:AVCaptureSessionPresetHigh];
   // If this video device also provides audio, don't use another audio device
   if ([self selectedVideoDeviceProvidesAudio])
      [self setSelectedAudioDevice:nil];
   
   [[self session] commitConfiguration];
}

- (AVCaptureDevice *)selectedAudioDevice
{
   return [audioDeviceInput device];
}

- (void)setSelectedAudioDevice:(AVCaptureDevice *)selectedAudioDevice
{
   [[self session] beginConfiguration];
   
   if ([self audioDeviceInput])
   {
      // Remove the old device input from the session
      [session removeInput:[self audioDeviceInput]];
      [self setAudioDeviceInput:nil];
   }
   
   if (selectedAudioDevice && ![self selectedVideoDeviceProvidesAudio])
   {
      NSError *error = nil;
      
      // Create a device input for the device and add it to the session
      AVCaptureDeviceInput *newAudioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:selectedAudioDevice error:&error];
      if (newAudioDeviceInput == nil) {
         dispatch_async(dispatch_get_main_queue(), ^(void) {
            [NSApp presentError:error];
         });
      }
      else
      {
         if (![selectedAudioDevice supportsAVCaptureSessionPreset:[session sessionPreset]])
            [[self session] setSessionPreset:AVCaptureSessionPresetHigh];
         
         [[self session] addInput:newAudioDeviceInput];
         [self setAudioDeviceInput:newAudioDeviceInput];
      }
   }
   
   [[self session] commitConfiguration];
}

#pragma mark - Device Properties

+ (NSSet *)keyPathsForValuesAffectingSelectedVideoDeviceProvidesAudio
{
   return [NSSet setWithObjects:@"selectedVideoDevice", nil];
}

- (BOOL)selectedVideoDeviceProvidesAudio
{
   return ([[self selectedVideoDevice] hasMediaType:AVMediaTypeMuxed] || [[self selectedVideoDevice] hasMediaType:AVMediaTypeAudio]);
}

+ (NSSet *)keyPathsForValuesAffectingVideoDeviceFormat
{
   return [NSSet setWithObjects:@"selectedVideoDevice.activeFormat", nil];
}

- (AVCaptureDeviceFormat *)videoDeviceFormat
{
   return [[self selectedVideoDevice] activeFormat];
}

- (void)setVideoDeviceFormat:(AVCaptureDeviceFormat *)deviceFormat
{
   NSError *error = nil;
   AVCaptureDevice *videoDevice = [self selectedVideoDevice];
   if ([videoDevice lockForConfiguration:&error]) {
      [videoDevice setActiveFormat:deviceFormat];
      [videoDevice unlockForConfiguration];
   } else {
      dispatch_async(dispatch_get_main_queue(), ^(void) {
         [NSApp presentError:error];
      });
   }
}

+ (NSSet *)keyPathsForValuesAffectingAudioDeviceFormat
{
   return [NSSet setWithObjects:@"selectedAudioDevice.activeFormat", nil];
}

- (AVCaptureDeviceFormat *)audioDeviceFormat
{
   return [[self selectedAudioDevice] activeFormat];
}

- (void)setAudioDeviceFormat:(AVCaptureDeviceFormat *)deviceFormat
{
   NSError *error = nil;
   AVCaptureDevice *audioDevice = [self selectedAudioDevice];
   if ([audioDevice lockForConfiguration:&error]) {
      [audioDevice setActiveFormat:deviceFormat];
      [audioDevice unlockForConfiguration];
   } else {
      dispatch_async(dispatch_get_main_queue(), ^(void) {
         [NSApp presentError:error];
      });
   }
}

+ (NSSet *)keyPathsForValuesAffectingFrameRateRange
{
   return [NSSet setWithObjects:@"selectedVideoDevice.activeFormat.videoSupportedFrameRateRanges", @"selectedVideoDevice.activeVideoMinFrameDuration", nil];
}

- (AVFrameRateRange *)frameRateRange
{
   AVFrameRateRange *activeFrameRateRange = nil;
   for (AVFrameRateRange *frameRateRange in [[[self selectedVideoDevice] activeFormat] videoSupportedFrameRateRanges])
   {
      if (CMTIME_COMPARE_INLINE([frameRateRange minFrameDuration], ==, [[self selectedVideoDevice] activeVideoMinFrameDuration]))
      {
         activeFrameRateRange = frameRateRange;
         break;
      }
   }
   
   return activeFrameRateRange;
}

- (void)setFrameRateRange:(AVFrameRateRange *)frameRateRange
{
   NSError *error = nil;
   if ([[[[self selectedVideoDevice] activeFormat] videoSupportedFrameRateRanges] containsObject:frameRateRange])
   {
      if ([[self selectedVideoDevice] lockForConfiguration:&error]) {
         [[self selectedVideoDevice] setActiveVideoMinFrameDuration:[frameRateRange minFrameDuration]];
         [[self selectedVideoDevice] unlockForConfiguration];
      } else {
         dispatch_async(dispatch_get_main_queue(), ^(void) {
            [NSApp presentError:error];
         });
      }
   }
}

- (IBAction)lockVideoDeviceForConfiguration:(id)sender
{
   if ([(NSButton *)sender state] == NSOnState)
   {
      [[self selectedVideoDevice] lockForConfiguration:nil];
   }
   else
   {
      [[self selectedVideoDevice] unlockForConfiguration];
   }
}

#pragma mark - Recording

+ (NSSet *)keyPathsForValuesAffectingHasRecordingDevice
{
   return [NSSet setWithObjects:@"selectedVideoDevice", @"selectedAudioDevice", nil];
}

- (BOOL)hasRecordingDevice
{
   return ((videoDeviceInput != nil) || (audioDeviceInput != nil));
}

+ (NSSet *)keyPathsForValuesAffectingRecording
{
   return [NSSet setWithObject:@"movieFileOutput.recording"];
}

- (BOOL)isRecording
{
   return [[self movieFileOutput] isRecording];
}


- (void)setRecording:(BOOL)record mitLeserPfad:(NSString*)leserpfad
{
 //  NSDate *now = [[NSDate alloc] init];
 //  long t1 = (int)now.timeIntervalSince1970 - startzeit;
   //NSLog(@"setRecording leserpfad: %@",leserpfad);
   LeserPfad = leserpfad;
   if (record)
   {
      if ([self isRecording])
      {
         NSLog(@"isRecording");
         return;
         
      }
    
      tempDirPfad = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
      //NSLog(@"tempDirPfad: %@",tempDirPfad);
      tempfileURL = [NSURL fileURLWithPath:tempDirPfad isDirectory:YES];
      //NSLog(@"tempfileURL: %@",tempfileURL);
     // NSDate *now = [[NSDate alloc] init];
      //long t2 = (int)now.timeIntervalSince1970 - startzeit;
      //NSLog(@"setRecording t2: %ld",t2);

     // [self refreshDevices];
     // NSString* tempPfad =[[tempDirPfad stringByAppendingPathComponent:@"tempAufnahme"] stringByAppendingPathExtension:@"mov"];
     //[[self movieFileOutput] setDelegate:self];
      NSString* tempPfad =[tempDirPfad  stringByAppendingPathExtension:@"mov"];
      
      NSURL* tempAufnahmeURL = [NSURL  fileURLWithPath:tempPfad];
     // now = [[NSDate alloc] init];
     // long t3 = (int)now.timeIntervalSince1970 - startzeit;
     // NSLog(@"setRecording t3: %ld",t3);

      [[self movieFileOutput] startRecordingToOutputFileURL:tempAufnahmeURL  recordingDelegate:self];
   
   }
   else
   {
      aufnahmezeit = CMTimeGetSeconds([[self movieFileOutput] recordedDuration]);
      //NSLog(@"aufnahmezeit: %d",aufnahmezeit);
      [[self movieFileOutput] stopRecording];
     
   }
}

- (void)AufnahmeTimerFunktion:(NSTimer*)derTimer
{
   NSLog(@"AufnahmeTimerFunktion");
}


+ (NSSet *)keyPathsForValuesAffectingAvailableSessionPresets
{
   return [NSSet setWithObjects:@"selectedVideoDevice", @"selectedAudioDevice", nil];
}

- (NSArray *)availableSessionPresets
{
   NSArray *allSessionPresets = [NSArray arrayWithObjects:
                                 AVCaptureSessionPresetLow,
                                 AVCaptureSessionPresetMedium,
                                 AVCaptureSessionPresetHigh,
                                 AVCaptureSessionPreset320x240,
                                 AVCaptureSessionPreset352x288,
                                 AVCaptureSessionPreset640x480,
                                 AVCaptureSessionPreset960x540,
                                 AVCaptureSessionPreset1280x720,
                                 AVCaptureSessionPresetPhoto,
                                 nil];
   
   NSMutableArray *availableSessionPresets = [NSMutableArray arrayWithCapacity:9];
   for (NSString *sessionPreset in allSessionPresets) {
      if ([[self session] canSetSessionPreset:sessionPreset])
         [availableSessionPresets addObject:sessionPreset];
   }
   
   return availableSessionPresets;
}

#pragma mark - Audio Preview

- (float)previewVolume
{
   return [[self audioPreviewOutput] volume];
}

- (void)setPreviewVolume:(float)newPreviewVolume
{
   [[self audioPreviewOutput] setVolume:newPreviewVolume];
}

- (void)updateAudioLevels:(NSTimer *)timer
{
   
   NSInteger channelCount = 0;
   float decibels = 0.f;
   // Sum all of the average power levels and divide by the number of channels
   for (AVCaptureConnection *connection in [[self movieFileOutput] connections])
   {
      for (AVCaptureAudioChannel *audioChannel in [connection audioChannels])
      {
         decibels += [audioChannel averagePowerLevel];
         channelCount += 1;
      }
   }
   
   decibels /= channelCount;
   
   //[[self audioLevelMeter] setFloatValue:(pow(10.f, 0.05f * decibels) * 20.0f)];
   AufnahmeLevelWert =2*(pow(10.f, 0.05f * decibels) * 20.0f);
   double duration;
  // NSMutableDictionary* recordDic = [[NSMutableDictionary alloc]initWithCapacity:0];
   //if ([self movieFileOutput].recording)
   {
   CMTime cmtduration = [[self movieFileOutput] recordedDuration];
   duration =CMTimeGetSeconds(cmtduration);
     // NSLog(@"duration: %f",duration);
   }
   NSNotificationCenter * nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"levelmeter" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSNumber numberWithFloat:(pow(10.f, 0.05f * decibels) * 20.0f)] ,@"level",
                                                                [NSNumber numberWithInteger:duration] ,@"duration",nil]];

}
- (float)AufnahmeLevel
{
   return AufnahmeLevelWert;
}

- (void)trim
{

   NSOpenPanel *trimPanel = [NSOpenPanel openPanel];
   
   
   [trimPanel beginSheetModalForWindow:[self RecorderFenster] completionHandler:^(NSInteger result)
    {
      
       if (result == NSModalResponseOK)
       {
          
          
          
          NSString* testpfad = [[[NSHomeDirectory()stringByAppendingPathComponent:@"Documents/Lesebox"]stringByAppendingPathComponent:@"trimm"]stringByAppendingPathExtension:@"m4a"];
          
          
          [self  trimFileAtURL:[trimPanel URL] toURL:[NSURL fileURLWithPath:testpfad]];
       }
       else
          
       {
          [trimPanel orderOut:self];
          //[self presentError:error modalForWindow:[self RecorderFenster] delegate:self didPresentSelector:@selector(didPresentErrorWithRecovery:contextInfo:) contextInfo:NULL];
       }
       
       
       
    }];
   
}

- (void)cut
{
   
   NSSavePanel *trimPanel = [NSOpenPanel openPanel];
   [trimPanel beginSheetModalForWindow:[self RecorderFenster] completionHandler:^(NSInteger result)
    {
       
       if (result == NSModalResponseOK)
       {
           NSString* testpfad = [[[NSHomeDirectory()stringByAppendingPathComponent:@"Documents/Lesebox"]stringByAppendingPathComponent:@"cut"]stringByAppendingPathExtension:@"m4a"];
          
          [self  cutFileAtURL:[trimPanel URL] toURL:[NSURL fileURLWithPath:testpfad]];
       }
       else
          
       {
          [trimPanel orderOut:self];
          //[self presentError:error modalForWindow:[self RecorderFenster] delegate:self didPresentSelector:@selector(didPresentErrorWithRecovery:contextInfo:) contextInfo:NULL];
       }
       
       
       
    }];
   
}
- (int)cutFileAtURL:(NSURL*)sourceURL toURL:(NSURL*)destURL
{
   int cutsuccess=0;
   //NSLog(@"cutFileAtURL: \n\tsourceURL: %@\n\tdestURL: %@",sourceURL,destURL);
   // http://www.rockhoppertech.com/blog/ios-trimming-audio-files
   // http://stackoverflow.com/questions/23752671/avassetexportsession-not-exporting-metadata
   AVAsset* asset = [AVAsset assetWithURL:sourceURL];
   {
      if ( [[NSFileManager defaultManager] fileExistsAtPath:[destURL path]])
      {
         NSError* err;
         [[NSFileManager defaultManager] removeItemAtURL:destURL error:&err];
      }
      if ( [[NSFileManager defaultManager] fileExistsAtPath:[sourceURL path]])
      {
         AVAssetExportSession* exporter = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];

         //NSArray* types =[exporter supportedFileTypes];
         //NSLog(@"types: %@",[types description]);
         
         exporter.outputFileType = AVFileTypeAppleM4A;
         
         exporter.outputURL = destURL;
         
         // double duration = CMTimeGetSeconds(asset.duration);
         
         CMTime cmtduration = (asset.duration);
         //NSLog(@"duration raw: %lld",cmtduration.value);
         double duration =CMTimeGetSeconds(cmtduration);
         //NSLog(@"cut duration seconds: %f",duration);
         CMTime startTime = CMTimeMake(0, 1);
         CMTime cutstartTime = CMTimeMake(1, 1);
         CMTime cutendTime = CMTimeMake(duration-1, 1);
         CMTimeRange cutRange = CMTimeRangeFromTimeToTime(startTime, cutendTime);
         exporter.timeRange = cutRange;
         
         
         NSArray* tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
         if (tracks.count == 0)
         {
            return cutsuccess;
         }
         
         [exporter exportAsynchronouslyWithCompletionHandler:^{
            //NSLog(@"Export Session Status: %ld", (long)[exporter status]);
            
            switch ([exporter status])
            {
               case AVAssetExportSessionStatusCompleted:
                  NSLog(@"Export sucess");break;
               case AVAssetExportSessionStatusFailed:
                  NSLog(@"Export failed: %@", [[exporter error] localizedDescription]);break;
               case AVAssetExportSessionStatusCancelled:
                  NSLog(@"Export canceled");break;
               default:
                  break;
            }
         }];
         cutsuccess = (int)[exporter status];
         //NSLog(@"cut Export err: %@", [[exporter error] localizedDescription]);
      }
      else
      {
         
      }
      
      
      
   }
   return cutsuccess;
}
- (void)trimFileAtURL:(NSURL*)sourceURL toURL:(NSURL*)destURL
{
   // http://www.rockhoppertech.com/blog/ios-trimming-audio-files
   // http://stackoverflow.com/questions/23752671/avassetexportsession-not-exporting-metadata
   AVAsset* asset = [AVAsset assetWithURL:sourceURL];
   {
      if ( [[NSFileManager defaultManager] fileExistsAtPath:[destURL path]])
      {
         NSError* err;
         [[NSFileManager defaultManager] removeItemAtURL:destURL error:&err];
      }
     if ( [[NSFileManager defaultManager] fileExistsAtPath:[sourceURL path]])
     {
        AVAssetExportSession* exporter = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
        NSArray* types =[exporter supportedFileTypes];
        //NSLog(@"types: %@",[types description]);
        
        //NSLog(@"types: %@",[types description]);
        //ev. AVAssetExportPresetPassthrough
        exporter.outputFileType = AVFileTypeAppleM4A;
       
        exporter.outputURL = destURL;
        
       // double duration = CMTimeGetSeconds(asset.duration);

        CMTime cmtduration = asset.duration;
        NSLog(@"duration: %lld",cmtduration.value);
        double duration =cmtduration.value;
        CMTime startTime = CMTimeMake(0, 1);
        CMTime trimstartTime = CMTimeMake(20, 1);
        CMTimeRange startTrimRange = CMTimeRangeFromTimeToTime(startTime, trimstartTime);
        //exporter.timeRange = startTrimRange;

        CMTime endTime = CMTimeMake(duration, 1);
        CMTime trimendTime = CMTimeMake(duration-5000, 1);
        CMTimeRange endTrimRange = CMTimeRangeFromTimeToTime(trimendTime, endTime);
    //    exporter.timeRange = endTrimRange;
        
        CMTimeRange range = CMTimeRangeMake(startTime, trimendTime);
        exporter.timeRange = range;

        
        NSArray* tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
        if (tracks.count == 0)
        {
           return;
        }
        AVAssetTrack * trimTrack = tracks[0];
        AVMutableAudioMix* trimMix = [AVMutableAudioMix audioMix];
        AVMutableAudioMixInputParameters* trimParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:trimTrack];
        [trimParameters setVolume:1.0 atTime: startTime];
        
        //[trimParameters setVolumeRampFromStartVolume:0.0 toEndVolume:1.0 timeRange:startTrimRange];
        trimMix.inputParameters = [NSArray arrayWithObject:trimParameters];
        exporter.audioMix = trimMix;
        
        [exporter exportAsynchronouslyWithCompletionHandler:^{
         NSLog(@"Export Session Status: %ld", (long)[exporter status]);
           switch ([exporter status])
           {
              case AVAssetExportSessionStatusCompleted:
                 NSLog(@"Export sucess");break;
              case AVAssetExportSessionStatusFailed:
                 NSLog(@"Export failed: %@", [[exporter error] localizedDescription]);break;
              case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Export canceled");break;
              default:
                 break;
           }
        }];
        
     }
      else
      {
         
      }
      
      
    
   }
}
#pragma mark - Transport Controls

- (IBAction)stop:(id)sender
{
   
  // [self setTransportMode:AVCaptureDeviceTransportControlsNotPlayingMode speed:0.f forDevice:[self selectedVideoDevice]];
   [self setTransportMode:AVCaptureDeviceTransportControlsNotPlayingMode speed:0.f forDevice:[self selectedAudioDevice]];

}

+ (NSSet *)keyPathsForValuesAffectingPlaying
{
   return [NSSet setWithObjects:@"selectedVideoDevice.transportControlsPlaybackMode", @"selectedVideoDevice.transportControlsSpeed",nil];
}

- (BOOL)isPlaying
{
   
   AVCaptureDevice *device = [self selectedVideoDevice];
   return ([device transportControlsSupported] &&
           [device transportControlsPlaybackMode] == AVCaptureDeviceTransportControlsPlayingMode &&
           [device transportControlsSpeed] == 1.f);
}

- (void)setPlaying:(BOOL)play
{
   NSLog(@"AVVRecorder startAVPlay");
   AVCaptureDevice *device = [self selectedAudioDevice];
   [self setTransportMode:AVCaptureDeviceTransportControlsPlayingMode speed:play ? 1.f : 0.f forDevice:device];
}

+ (NSSet *)keyPathsForValuesAffectingRewinding
{
   return [NSSet setWithObjects:@"selectedVideoDevice.transportControlsPlaybackMode", @"selectedVideoDevice.transportControlsSpeed",nil];
}

- (BOOL)isRewinding
{
   AVCaptureDevice *device = [self selectedVideoDevice];
   return [device transportControlsSupported] && ([device transportControlsSpeed] < -1.f);
}

- (void)setRewinding:(BOOL)rewind
{
   AVCaptureDevice *device = [self selectedVideoDevice];
   [self setTransportMode:[device transportControlsPlaybackMode] speed:rewind ? -2.f : 0.f forDevice:device];
}

+ (NSSet *)keyPathsForValuesAffectingFastForwarding
{
   return [NSSet setWithObjects:@"selectedVideoDevice.transportControlsPlaybackMode", @"selectedVideoDevice.transportControlsSpeed",nil];
}

- (BOOL)isFastForwarding
{
   AVCaptureDevice *device = [self selectedVideoDevice];
   return [device transportControlsSupported] && ([device transportControlsSpeed] > 1.f);
}

- (void)setFastForwarding:(BOOL)fastforward
{
   AVCaptureDevice *device = [self selectedVideoDevice];
   [self setTransportMode:[device transportControlsPlaybackMode] speed:fastforward ? 2.f : 0.f forDevice:device];
}

- (void)setTransportMode:(AVCaptureDeviceTransportControlsPlaybackMode)playbackMode speed:(AVCaptureDeviceTransportControlsSpeed)speed forDevice:(AVCaptureDevice *)device
{
   NSError *error = nil;
   if ([device transportControlsSupported])
   {
      if ([device lockForConfiguration:&error])
      {
         [device setTransportControlsPlaybackMode:playbackMode speed:speed];
         [device unlockForConfiguration];
      }
      else
      {
         dispatch_async(dispatch_get_main_queue(), ^(void)
                        {
                           [NSApp presentError:error];
                        });
      }
   }
}

- (void)clean
{
NSError *error = nil;
[[NSFileManager defaultManager] removeItemAtURL:self.tempDirURL error:&error];
   
}
#pragma mark - Delegate methods

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
   NSDate *now = [[NSDate alloc] init];
   long t3 = now.timeIntervalSince1970/1000000 - startzeit;
   //NSLog(@"setRecording t3: %ld",t3);

   //NSLog(@"Did start recording to %@", [fileURL description]);
  
   NSNotificationCenter * nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"recording" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"record"]];

}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
   NSLog(@"Did pause recording to %@", [fileURL description]);
   
   
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
   NSNotificationCenter * nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"recording" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"record"]];

   NSLog(@"Did resume recording to %@", [fileURL description]);
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput willFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections dueToError:(NSError *)error
{
   dispatch_async(dispatch_get_main_queue(), ^(void) {
      [NSApp presentError:error];
   });
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)recordError
{
   float zeit = CMTimeGetSeconds([captureOutput recordedDuration]);
   aufnahmezeit = [[NSNumber numberWithFloat:zeit]intValue];
  // aufnahmezeit = lrintf(zeit);
  
   //NSLog(@"didFinishRecordingToOutputFileAtURL: %@ an Leserpfad : %@ zeit: %f aufnahmezeit: %d",outputFileURL,LeserPfad,zeit,aufnahmezeit);
   
   NSNotificationCenter * nc=[NSNotificationCenter defaultCenter];
   NSMutableDictionary* saveDic = [[NSMutableDictionary alloc]initWithCapacity:0];
   //   [nc postNotificationName:@"recording" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"record"]];
   [saveDic setObject:[NSNumber numberWithInt:0] forKey:@"record"];
   
   if (recordError != nil && [[[recordError userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey] boolValue] == NO) // Fehler, aufraeumen
   {
      [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
      dispatch_async(dispatch_get_main_queue(), ^(void) {
         [NSApp presentError:recordError];
      });
      [saveDic setObject:[NSNumber numberWithLong:aufnahmezeit] forKey:@"aufnahmezeit"];

      [saveDic setObject:[NSNumber numberWithInt:0] forKey:@"recorderfolg"];
      NSAlert *Warnung = [[NSAlert alloc] init];
      [Warnung addButtonWithTitle:@"OK"];
      [Warnung setMessageText:@"Fehler beim Aufnehmen. Die Aufnahme wird entfernt."];
      
      [Warnung setAlertStyle:NSWarningAlertStyle];
      
      //[Warnung setIcon:RPImage];
      int antwort=[Warnung runModal];
      
      NSLog(@"Fehler beim Aufnehmen. Die Aufnahme wird entfernt.");
      [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
      
   }
   else
      
   {
      [saveDic setObject:[NSNumber numberWithInt:1] forKey:@"recorderfolg"];
      [saveDic setObject:[NSNumber numberWithInt:aufnahmezeit] forKey:@"aufnahmezeit"];

      // Move the recorded temporary file to a user-specified location
      //     NSSavePanel *savePanel = [NSSavePanel savePanel];
      //  [savePanel setAllowedFileTypes:[NSArray arrayWithObject:AVFileTypeQuickTimeMovie]];
      //     [savePanel setCanSelectHiddenExtension:YES];
      
      //      long antwort = [savePanel runModal];
      //     NSLog(@"antwort: %ld URL: %@",antwort,[savePanel URL]);
      
      // tempOrdner fuer getrimmte tempAufnahme
      
      NSString* tempTrimmPfad =[tempDirPfad   stringByAppendingPathExtension:@"m4a"];
    //  NSLog(@"tempTrimmPfad: %@",tempTrimmPfad);
      NSURL* tempTrimmURL = [NSURL  fileURLWithPath:tempTrimmPfad];
      
      int cuterfolg = [self  cutFileAtURL:outputFileURL toURL:tempTrimmURL];
      //NSLog(@"cuterfolg: %d",cuterfolg);
      self.hiddenAufnahmePfad = [tempTrimmURL path]; // Pfad fuer Abspielen im Player
      
      [saveDic setObject:tempTrimmURL forKey:@"desturl"];
      
      [nc postNotificationName:@"recording" object:self userInfo:saveDic];
      
      return;
      /*
      [[NSFileManager defaultManager] removeItemAtURL:[NSURL  fileURLWithPath:LeserPfad] error:nil]; // attempt to remove file at the desired save location before moving the recorded file to that location
      
      NSError *error = nil;
      if ([[NSFileManager defaultManager] moveItemAtURL:tempTrimmURL toURL:[NSURL  fileURLWithPath:LeserPfad] error:&error]) // move OK
      {
         NSLog(@"move 1");
         // Platz machen
         [[NSFileManager defaultManager] removeItemAtURL:tempTrimmURL error:nil];
         // Movie abspielen
         //   [[NSWorkspace sharedWorkspace] openURL:[savePanel URL]];
      }
      else // Fehler mit move
      {
         NSAlert *Warnung = [[NSAlert alloc] init];
         [Warnung addButtonWithTitle:@"OK"];
         // [Warnung setMessageText:NSLocalizedString(@"No Marked Records",@"Keine markierten Aufnahmen")];
         [Warnung setMessageText:@"Fehler beim Sichern der Aufnahmen: Keine markierten Aufnahmen."];
         
         [Warnung setAlertStyle:NSWarningAlertStyle];
         
         //[Warnung setIcon:RPImage];
         int antwort=[Warnung runModal];
         
         NSLog(@"Fehler beim Sichern der Aufnahmen");
         [[NSFileManager defaultManager] removeItemAtURL:tempTrimmURL error:nil];
      }
      return;
      NSSavePanel *savePanel = [NSSavePanel savePanel];
      
      savePanel.allowedFileTypes = [NSArray arrayWithObjects:@"m4a",@"mov",nil];
      [savePanel beginSheetModalForWindow:[self RecorderFenster] completionHandler:^(NSInteger result)
       {
          NSLog(@"result: %ld",(long)result);
          NSError *error = nil;
          if (result == NSOKButton)
          {
             
             NSLog(@"savePanel URL: %@",[savePanel URL]);
             
             [[NSFileManager defaultManager] removeItemAtURL:[savePanel URL] error:nil]; // attempt to remove file at the desired save location before moving the recorded file to that location
             if ([[NSFileManager defaultManager] moveItemAtURL:tempTrimmURL toURL:[savePanel URL] error:&error])
             {
                NSLog(@"savePanel move 1");
                // Platz machen
                [[NSFileManager defaultManager] removeItemAtURL:tempTrimmURL error:nil];
                // Movie abspielen
                //   [[NSWorkspace sharedWorkspace] openURL:[savePanel URL]];
             }
             else
                
             {
                NSLog(@"savePanel move 0");
                [savePanel orderOut:self];
                //[self presentError:error modalForWindow:[self RecorderFenster] delegate:self didPresentSelector:@selector(didPresentErrorWithRecovery:contextInfo:) contextInfo:NULL];
             }
          }
          else
          {
             
             // remove the temporary recording file if it's not being saved
             [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
             // getrimmte Aufnahme entfernen, sofern nicht gesichert
             //            [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:tempAufnahmePfad] error:nil];
          }
       }];
      */
   }
   //AVCaptureInput* input = [[self session].inputs objectAtIndex:0];
   //[[self session] removeInput:input];
   //[[self session] stopRunning];
}

- (BOOL)captureOutputShouldProvideSampleAccurateRecordingStart:(AVCaptureOutput *)captureOutput
{
   // We don't require frame accurate start when we start a recording. If we answer YES, the capture output
   // applies outputSettings immediately when the session starts previewing, resulting in higher CPU usage
   // and shorter battery life.
   return NO;
}



@end
