//
//  rGrabber.h
//  RecPlayII
//
//  Created by Sysadmin on 03.12.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Quicktime/Quicktime.h"

//#import "rKanal.h"

@class rKanal;

extern NSString * SeqGrabChannelKey;

// following notifications send the SeqGrab * instance as the [notification object], and 
// the SGChan * in question as the value for the one key in the [notification userInfo] dictionary,
// where the key is SeqGrabChannelKey (above)

extern NSString * SeqGrabChannelRemovedNotification; 
extern NSString * SeqGrabChannelAddedNotification;

@interface rGrabber : NSObject 
{
id					Master;
SeqGrabComponent	Grabber;
SGChannel			SoundKanal;
NSMutableArray*		SoundKanalArray;
NSString*			AufnahmePfad;
long				AufnahmeFlags;
BOOL				RecordingOK;
BOOL				ChannelOK;
BOOL				PreviewingOK;
long				ChannelUsage;
NSString*			SicherAufnahmePfad;
long				SicherAufnahmeFlags;
int					Idletakt;
float				Level;
NSMutableArray*		LevelArray;
NSData*				GrabberDaten;
}

- (id)init;

- (NSArray*)SoundKanalArray;
- (OSStatus)addKanalZuArray:(rKanal*)derKanal;
- (OSStatus)removeKanal;
- (NSArray*)getSoundKanalArray;
- (SeqGrabComponent)Grabber;
- (BOOL)setAufnahmePfad:(NSString*)derAufnahmePfad flags:(long)flags;
- (OSStatus)setGrabberSettings:(NSData*)dieDaten;
- (NSData *)GrabberSettings;
- (OSErr)prepare;
- (OSStatus)preview;
- (OSStatus)startRecord;
- (OSStatus)stopRecord;
- (void)setMaster:(id)derMaster;
- (BOOL)isRecording;
- (BOOL)isPreviewing;
- (void)startTimer;
- (void)startLevelTimer:(NSTimer*)derTimer;
- (OSStatus)Idlefunktion;

- (OSErr)GrabberSchliessen;
@end
