//
//  rKanal.h
//  RecPlayII
//
//  Created by Sysadmin on 03.12.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Quicktime/Quicktime.h"
#import "Quicktime/QuicktimeComponents.h"

#import <AudioUnit/AudioUnit.h>
#import "rGrabber.h"
//#import "rAudioSettings.h"

// notifications
extern NSString * SGAudioDeviceListChangedNotification;
extern NSString * SGAudioRecordDeviceDiedNotification;
extern NSString * SGAudioRecordDeviceHoggedChangedNotification;
extern NSString * SGAudioRecordDeviceInUseChangedNotification;
extern NSString * SGAudioRecordDeviceStreamFormatChangedNotification;
extern NSString * SGAudioRecordDeviceStreamFormatListChangedNotification;
extern NSString * SGAudioRecordDeviceInputSelectionNotification;
extern NSString * SGAudioRecordDeviceInputListChangedNotification;
extern NSString * SGAudioPreviewDeviceDiedNotification;
extern NSString * SGAudioPreviewDeviceHoggedChangedNotification;
extern NSString * SGAudioPreviewDeviceInUseChangedNotification;
extern NSString * SGAudioPreviewDeviceStreamFormatChangedNotification;
extern NSString * SGAudioPreviewDeviceStreamFormatListChangedNotification;
extern NSString * SGAudioPreviewDeviceOutputSelectionChangedNotification;
extern NSString * SGAudioPreviewDeviceOutputListChangedNotification;
extern NSString * SGAudioOutputStreamFormatChangedNotification;

#define kMaxFXUnits     6

@interface rKanal : NSObject 
{
rGrabber*		SG;
//SGChannel*		Chan;
//rAudioSettings*	AudioSettings;
SGChannel		SoundKanal;
BOOL			mDoInitFXUnits;
QTMLMutex       mMutex;
Float32 *       mLevelsArray;
UInt32          mLevelsArraySize;
UInt32          mChannelNumber;
UInt32          mIndex;
double  mMinDB;
double	mMaxDB;
double 	mMinValue;
double 	mMaxValue; 
int		mNumChannels;
float  *mMeterValues;
float  *mOldMeterValues;
int	   *mClipValues;
UserData	UserDaten;
  rKanal*           mChan;
}
- (OSStatus)getPropertyInfoWithClass:(ComponentPropertyClass)theClass
                                    id:(ComponentPropertyID)theID
                                    type:(ComponentValueType*)type
                                    size:(ByteCount*)sz
                                    flags:(UInt32*)flags;

- (OSStatus)getPropertyWithClass:(ComponentPropertyClass)theClass
                                    id:(ComponentPropertyID)theID
                                    size:(ByteCount)sz
                                    address:(ComponentValuePtr)addr
                                    sizeUsed:(ByteCount*)szUsed;
            
- (OSStatus)setPropertyWithClass:(ComponentPropertyClass)theClass
                                    id:(ComponentPropertyID)theID
                                    size:(ByteCount)sz
                                    address:(ConstComponentValuePtr)addr;
                                    
- (OSStatus)setSGAudioPropertyWithClass:(ComponentPropertyClass)theClass
                                id:(ComponentPropertyID)theID
                                size:(ByteCount)sz
                                address:(ConstComponentValuePtr)addr;

- (id)initWithSeqGrab:(rGrabber*)derGrabber channelComponent:(SGChannel)chn;
- (id)initWithSeqGrab:(rGrabber*)derGrabber;

- (SGChannel)SoundKanal;
- (void)setUsage:(long)usage;
- (long)usage;

//- (OSStatus)setOutputFormat:(NSData*)dieDaten;
// convenience functions which use the property methods above
- (NSArray*)deviceList;
- (NSArray*)recordCapableDeviceList;
- (NSArray*)previewCapableDeviceList;
- (void) setNumChannels: (int) num;
- (float)AufnahmeLevel;
- (BOOL)setGain:(float)derGain;

- (OSStatus)sgAudioCallbackRender:(SGAudioCallbackFlags *)ioFlags
						timestamp:(const AudioTimeStamp *)inTimeStamp
					   numPackets:(const UInt32 *)inNumberPackets
						   buffer:(const AudioBufferList *)inData
					  packetDescs:(const AudioStreamPacketDescription*)inPacketDescriptions;

                                                            
- (NSString*)summaryString;
- (NSArray*)deviceList;
- (NSArray*)recordCapableDeviceList;
@end
