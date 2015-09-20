//
//  rKanal.mm
//  RecPlayII
//
//  Created by Sysadmin on 03.12.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "rKanal.h"
#include <math.h>
#import "rAudioSettings.h"
#import "QuickTime/QuickTime.h"
#import "Quicktime/QuicktimeComponents.h"

double dbamp(double db) { return pow(10., 0.05 * db); }
double ampdb(double amp) { return 20. * log10(amp); }


NSString * SGAudioDeviceListChangedNotification                     = @"SGAudioDeviceListChangedNotification";
NSString * SGAudioRecordDeviceDiedNotification                      = @"SGAudioRecordDeviceDiedNotification";
NSString * SGAudioRecordDeviceHoggedChangedNotification             = @"SGAudioRecordDeviceHoggedChangedNotification";
NSString * SGAudioRecordDeviceInUseChangedNotification              = @"SGAudioRecordDeviceInUseChangedNotification";
NSString * SGAudioRecordDeviceStreamFormatChangedNotification       = @"SGAudioRecordDeviceStreamFormatChangedNotification";
NSString * SGAudioRecordDeviceStreamFormatListChangedNotification   = @"SGAudioRecordDeviceStreamFormatListChangedNotification";
NSString * SGAudioRecordDeviceInputSelectionNotification            = @"SGAudioRecordDeviceInputSelectionNotification";
NSString * SGAudioRecordDeviceInputListChangedNotification          = @"SGAudioRecordDeviceInputListChangedNotification";
NSString * SGAudioPreviewDeviceDiedNotification                     = @"SGAudioPreviewDeviceDiedNotification";
NSString * SGAudioPreviewDeviceHoggedChangedNotification            = @"SGAudioPreviewDeviceHoggedChangedNotification";
NSString * SGAudioPreviewDeviceInUseChangedNotification             = @"SGAudioPreviewDeviceInUseChangedNotification";
NSString * SGAudioPreviewDeviceStreamFormatChangedNotification      = @"SGAudioPreviewDeviceStreamFormatChangedNotification";
NSString * SGAudioPreviewDeviceStreamFormatListChangedNotification  = @"SGAudioPreviewDeviceStreamFormatListChangedNotification";
NSString * SGAudioPreviewDeviceOutputSelectionChangedNotification   = @"SGAudioPreviewDeviceOutputSelectionChangedNotification";
NSString * SGAudioPreviewDeviceOutputListChangedNotification        = @"SGAudioPreviewDeviceOutputListChangedNotification";
NSString * SGAudioOutputStreamFormatChangedNotification             = @"SGAudioOutputStreamFormatChangedNotification";


static void 
sgAudioPropListenerCallback(ComponentInstance inComponent, 
                            ComponentPropertyClass inPropClass, 
                            ComponentPropertyID inPropID, 
                            void *inUserData);


@implementation rKanal
static OSStatus myPreMixSGAudioCallback(
    SGChannel		 	  				c,
    void *                  			inRefCon,
    SGAudioCallbackFlags *				ioFlags,
    const AudioTimeStamp *  			inTimeStamp,
    const UInt32 *          			inNumberPackets,
    const AudioBufferList * 			inData,
    const AudioStreamPacketDescription*	inPacketDescriptions);
    
    
static OSStatus
fxUnitInputProc(void *inRefCon, 
                AudioUnitRenderActionFlags *ioActionFlags, 
                const AudioTimeStamp *inTimeStamp, 
                UInt32 inBusNumber, 
                UInt32 inNumberFrames, 
                AudioBufferList *ioData);
    
static void 
sgAudioPropListenerCallback(ComponentInstance inComponent, 
                            ComponentPropertyClass inPropClass, 
                            ComponentPropertyID inPropID, 
                            void *inUserData);

static pascal Boolean
SeqGrabberModalFilterProc (DialogPtr theDialog, const EventRecord *theEvent,
						   short *itemHit, long refCon);


//@implementation rKanal



- (id)initWithSeqGrab:(rGrabber*)derGrabber channelComponent:(SGChannel)chn
{
	SoundKanal = chn;
	self = [self initWithSeqGrab:derGrabber];
	return self;
}



- (id)initWithSeqGrab:(rGrabber*)derGrabber
{
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(AudioEinstellungenAktion:)
			   name:@"open"
			 object:nil];

	mChannelNumber=0;
	mMeterValues = nil;
	mOldMeterValues = nil;

	mMinValue = 0.;
	mMinDB = ampdb(0.);
	mMaxValue = 1.;
	mMaxDB = ampdb(1.);

	mMutex = QTMLCreateMutex();
	OSStatus err=noErr;
	NSData* data=nil;
	ComponentPropertyInfo* cpi=NULL;
	BOOL audioComponentAlreadyOpened=(SoundKanal!=NULL);
	self =[super init];
	SG=derGrabber;
	if (false==audioComponentAlreadyOpened)//noch kein Kanal
	{
		err=SGNewChannel([derGrabber Grabber],SGAudioMediaType,&SoundKanal);
	}
	if (err)
	{
		[self release];
		return nil;
	}
	err=SGSetChannelRefCon(SoundKanal,(long)self);
	if (err)
	{
		[self release];
		return nil;
	}
	[SG addKanalZuArray:self];
	
	[self setUsage:seqGrabPreview + seqGrabRecord];
	
	//Als Listener für SGAudio Properties registrieren
    [self getPropertyWithClass:kComponentPropertyClassPropertyInfo
                                    id:kComponentPropertyInfoList
                                    size:sizeof(data)
                                    address:&data
                                    sizeUsed:NULL];
									
	cpi=(ComponentPropertyInfo*)[data bytes];
    if (cpi)
    {
        for (int i = 0; i < [data length]/sizeof(ComponentPropertyInfo); i++)
        {
            if (cpi[i].propFlags & kComponentPropertyFlagWillNotifyListeners)
            {
                QTAddComponentPropertyListener(SoundKanal, 
                    cpi[i].propClass, cpi[i].propID,
                    (QTComponentPropertyListenerUPP)sgAudioPropListenerCallback,
                    self);
            }
        }
    }
	
	// set the channel map on the record device to expressly indicate our desire to
    // receive all channels from the record device (a reasonable default)
	if (false == audioComponentAlreadyOpened)
    {
        AudioStreamBasicDescription devFormat;
        
        if (noErr == [self getPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice 
                        id: kQTSGAudioPropertyID_StreamFormat 
                        size:sizeof(devFormat) 
                        address:&devFormat 
                        sizeUsed:NULL])
        {
            SInt32 * map = (SInt32*)malloc(devFormat.mChannelsPerFrame * sizeof(SInt32));
            
            for (int i = 0; i < devFormat.mChannelsPerFrame; i++)
            {
                map[i] = i;
            }
            
            [self setPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice 
                    id: kQTSGAudioPropertyID_ChannelMap 
                    size: devFormat.mChannelsPerFrame * sizeof(SInt32) 
                    address: map];
            
            free(map);
        }
    }
    
	//WHackedTV SGAudioSettings: showPanel
	BOOL recordMetersWereEnabled, outputMetersWereEnabled, doEnable = YES;

        // enable level metering, and remember the previous state of
        // this property, so it can be restored after our dialog goes away
    [self getPropertyWithClass:kQTPropertyClass_SGAudioRecordDevice 
                            id:kQTSGAudioPropertyID_LevelMetersEnabled 
                            size:sizeof(recordMetersWereEnabled) 
                            address:&recordMetersWereEnabled 
                            sizeUsed:NULL];

    if (recordMetersWereEnabled != doEnable)
    {
        [self setSGAudioPropertyWithClass:kQTPropertyClass_SGAudioRecordDevice 
                                id:kQTSGAudioPropertyID_LevelMetersEnabled 
                                size:sizeof(doEnable)
                                address:&doEnable];
    }
	
	
	[self setNumChannels:1];
return self;
}

- (SGChannel)SoundKanal
{
return SoundKanal;
}

- (void)setUsage:(long)usage
{
SGSetChannelUsage(SoundKanal,usage);
}

- (long)usage
{
    long usage;
    SGGetChannelUsage(SoundKanal, &usage);
    return usage;
}



// for the duration of the SGAudioSettings dialog, we want to preview.  But several
// properties can only be set when the channel is not in recording or previewing mode,
// so we'll call this method to stop/start the preview if we receive a -2200 error
// on the first try
- (OSStatus)setSGAudioPropertyWithClass:(ComponentPropertyClass)theClass
                                id:(ComponentPropertyID)theID
                                size:(ByteCount)sz
                                address:(ConstComponentValuePtr)addr
{
    OSStatus err = noErr;
    err = [self setPropertyWithClass: theClass 
								 id: theID 
							   size: sz 
						    address: addr];
                            
    if (err == kQTPropertyAskLaterErr)
    {
//        [self stopChannelPreview];
OSErr err=noErr;
//err=SGStop(SoundKanal);
        
        err = [self setPropertyWithClass: theClass 
								 id: theID 
							   size: sz 
						    address: addr];
        
//        [self startChannelPreview];
//err=SGPrepare(SoundKanal,true,false);
//err=SGStartPreview(SoundKanal);
    }
    
    return err;
}

/*________________________________________________________________________________________
*/

/*___________________________________________________________________________________________
*/

- (OSStatus)getPropertyInfoWithClass:(ComponentPropertyClass)theClass
                                    id:(ComponentPropertyID)theID
                                    type:(ComponentValueType*)type
                                    size:(ByteCount*)sz
                                    flags:(UInt32*)flags
{ 
    return QTGetComponentPropertyInfo(SoundKanal, theClass, theID, type, sz, flags); 
}

/*___________________________________________________________________________________________
*/

- (OSStatus)getPropertyWithClass:(ComponentPropertyClass)theClass
                                    id:(ComponentPropertyID)theID
                                    size:(ByteCount)sz
                                    address:(ComponentValuePtr)addr
                                    sizeUsed:(ByteCount*)szUsed
{ 
    return QTGetComponentProperty(SoundKanal, theClass, theID, sz, addr, szUsed); 
}

/*___________________________________________________________________________________________
*/
            
- (OSStatus)setPropertyWithClass:(ComponentPropertyClass)theClass
                                id:(ComponentPropertyID)theID
                                size:(ByteCount)sz
                                address:(ConstComponentValuePtr)addr
{ 
    return QTSetComponentProperty(SoundKanal, theClass, theID, sz, addr); 
}

/*___________________________________________________________________________________________
*/
/*___________________________________________________________________________________________
*/

// The following three functions are for convenience in getting common properties

- (NSArray*)deviceList
{
    NSArray * devList = nil;
    //NSLog(@"Kanal:  DeviceListe");

    OSErr err=[self getPropertyWithClass: kQTPropertyClass_SGAudio 
                             id: kQTSGAudioPropertyID_DeviceListWithAttributes 
                           size: sizeof(NSArray*) 
                        address: &devList
                       sizeUsed: NULL];
	//NSLog(@"Kanal:  DeviceListe: err: %d",err);
	[devList retain];
	//NSLog(@"Kanal:  DeviceListe end: Liste: %@",[devList description]);
    return [devList autorelease];
}

/*___________________________________________________________________________________________
*/

/*___________________________________________________________________________________________
*/

- (void) setNumChannels: (int) num 
{
	if (mNumChannels != num) 
	{
		mNumChannels = num;
		if (mMeterValues != nil)
			free(mMeterValues);
		if (mOldMeterValues != nil)
			free(mOldMeterValues);
		if (mClipValues != nil)
			free(mClipValues);
		mMeterValues = (float *) calloc (2 * num, sizeof(float));
		mOldMeterValues = (float *) calloc (2 * num, sizeof(float));
		mClipValues = (int *) calloc (num, sizeof(int));
		
	}
}


- (BOOL)setGain:(float)derGain
{
	OSErr err=noErr;
	//gainControl setzen HardwareGainSicher speichern
	Float32 tempGain;
	BOOL mUseHardwareGain=YES;
    ComponentPropertyClass propClass = 
		(mUseHardwareGain) ? kQTPropertyClass_SGAudioRecordDevice 
						   : kQTPropertyClass_SGAudio;
	
	//DeviceChannelStrip UpdateGain
	UInt32 size = 0, flags = 0;
    Float32 * array = NULL;
    
    if (noErr == [self getPropertyInfoWithClass:propClass
												   id:kQTSGAudioPropertyID_PerChannelGain 
												 type:NULL 
												 size:&size flags:&flags]
		&& size && (flags & kComponentPropertyFlagCanGetNow))
	{
		Float32 * chanGains = (Float32*)malloc(size * sizeof(Float32));
		UInt32 numChannelGains = size/sizeof(Float32);
		
		// set all chanGains to -1, indicating that we wish to ignore them.
		// we will put non -1 values into the indeces we wish to set.
		for (int i = 0; i < size/sizeof(Float32); i++)
		{
			chanGains[i] = -1.;
			NSLog(@"chanGains: %f  i: %d",chanGains[i],i);
		}
		
		// loop through the channel strip array again, this time getting the appropriate
		// volume levels to set on the SGAudioChannel.
		
		chanGains[0] = derGain;
		chanGains[1] = derGain;
		
		
		
		
		err=[self setSGAudioPropertyWithClass:kQTPropertyClass_SGAudioRecordDevice 
												 id:kQTSGAudioPropertyID_PerChannelGain 
											   size:size
											address:chanGains];
		err=[self setSGAudioPropertyWithClass:kQTPropertyClass_SGAudio 
												 id:kQTSGAudioPropertyID_PerChannelGain 
											   size:size
											address:chanGains];
		
		if (chanGains)
			free(chanGains);
	}
	return err;
}

- (NSArray*)recordCapableDeviceList
{
    NSArray * devList = [self deviceList];
    NSMutableArray * myList = nil;
    
    if (devList)
    {
        myList = [NSMutableArray array];
        
        for (int i = 0; i < [devList count]; i++)
        {
            NSDictionary * devDict = [devList objectAtIndex:i];
            UInt32 key = kQTAudioDeviceAttribute_DeviceCanRecordKey;

            if (YES == [(NSNumber*)[devDict objectForKey:(id)key] boolValue])
                [myList addObject:devDict];
        }
    }
    
    return myList;
}



- (NSArray*)previewCapableDeviceList
{

    NSArray * devList = [self deviceList];
    NSMutableArray * myList = nil;
    
    if (devList)
    {
        myList = [NSMutableArray array];
        
        for (int i = 0; i < [devList count]; i++)
        {
            NSDictionary * devDict = [devList objectAtIndex:i];
            UInt32 key = kQTAudioDeviceAttribute_DeviceCanPreviewKey;

            if (YES == [(NSNumber*)[devDict objectForKey:(id)key] boolValue])
                [myList addObject:devDict];
        }
    }

    return myList;
}

- (float)  pixelForValue: (double) value inSize: (int) size 
{
	return size * ((value - mMinValue) / (mMaxValue - mMinValue));		// figure out what percentage the value is of the entire range
}

- (float)AufnahmeLevel
{

    Float32 amps[2] = { -FLT_MAX, -FLT_MAX };
    
   // QTMLGrabMutex(mMutex);
    OSErr err=noErr;
        //SGAudio * myAudi = [mParent sgchan];
        
        if (mLevelsArray == NULL)
        {    
            UInt32 size;
            
            err=[self getPropertyInfoWithClass:kQTPropertyClass_SGAudioRecordDevice 
                                                id:kQTSGAudioPropertyID_ChannelMap 
                                                type:NULL size:&size flags:NULL];
           //NSLog(@"getPropertyInfoWithClass: err: %d",err);
		   
			 if (size > 0)
            {
                SInt32 * map = (SInt32 *)malloc(size);
                
				err=  [self getPropertyWithClass:kQTPropertyClass_SGAudioRecordDevice 
                                                id:kQTSGAudioPropertyID_ChannelMap 
                                                size:size
                                                address:map sizeUsed:&size];
                //NSLog(@"getPropertyWithClass: err: %d",err);
				
                for (int i = 0; i < size/sizeof(SInt32); i++)
                {
                    if (mChannelNumber == map[i])
                    {
                        mIndex = i;
                        mLevelsArraySize = size; // SInt32 and Float32 are the same size
                        mLevelsArray = (Float32*)malloc(mLevelsArraySize); 
                        break;
                    }
                }
                free(map);
            }
        }
        
        
        if (mLevelsArray) // paranoia
        {
            // get the avg power level
            err= [self getPropertyWithClass:kQTPropertyClass_SGAudioRecordDevice 
                                    id:kQTSGAudioPropertyID_AveragePowerLevels 
                                    size:mLevelsArraySize 
                                    address:mLevelsArray sizeUsed:NULL];
           //NSLog(@"avg power level: getPropertyWithClass: err: %d",err);

			if (err==noErr)
			{
                amps[0] = mLevelsArray[mIndex];
            }
         
			/*   
            // get the peak-hold level
            err= [self getPropertyWithClass:kQTPropertyClass_SGAudioRecordDevice 
                                    id:kQTSGAudioPropertyID_PeakHoldLevels 
                                    size:mLevelsArraySize 
                                    address:mLevelsArray sizeUsed:NULL];
            //NSLog(@"peakhold level: getPropertyWithClass: err: %d",err);

			if (err==noErr)
			{
                amps[1] = mLevelsArray[mIndex];
            }
			*/
			amps[1]=0;
        }
    
    
    //QTMLReturnMutex(mMutex);
	int i=0;
	float Messwert=0;
	 //Aus WHackedTV MorizontalMeteringView
		mNumChannels=1;
		int numItems = mNumChannels * 2;
		
		for (i = 0; i < numItems; i++)
		 {
			float tempValue = dbamp(amps[i]); 
			//mOldMeterValues[i] = mMeterValues[i];
			float pixelValue = [self pixelForValue: tempValue inSize: (int) 255];
			float top = 255.0; //Max
			if (pixelValue < 0)
				pixelValue = 0;
			else if (pixelValue > top)
				pixelValue = top;
				if (i%2==0)//gerade, average level
				{
				Messwert=pixelValue;
				}
			mMeterValues[i] = pixelValue;
			}		
		
	
//NSLog(@"Messwert: %f",Messwert);
	return Messwert;
    //[mMeteringView updateMeters:amps];
}

/*________________________________________________________________________________________
*/
- (void)AudioEinstellungenAktion:(NSNotification*)note
{
NSLog(@"AudioEinstellungenAktion: %@",[[note userInfo]description]);

}
/*________________________________________________________________________________________
*/
- (NSString*)summaryString
{
	NSString * device = nil;
	NSDictionary * attribs = nil;
	NSString * retval = nil;
	
	[self getPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice 
                             id: kQTSGAudioPropertyID_DeviceAttributes 
                           size: sizeof(attribs) 
                        address: &attribs
                       sizeUsed: NULL];
					   
	device = [attribs objectForKey:(id)kQTAudioDeviceAttribute_DeviceNameKey];
	
	
	retval = [NSString stringWithFormat:@"[%p] SGAudio: %@", self, device];
	
	[attribs release];
	
	return retval;
}


/*________________________________________________________________________________________
*/

static OSStatus myPreMixSGAudioCallback(
    SGChannel		 	  				c,
    void *                  			inRefCon,
    SGAudioCallbackFlags *				ioFlags,
    const AudioTimeStamp *  			inTimeStamp,
    const UInt32 *          			inNumberPackets,
    const AudioBufferList * 			inData,
    const AudioStreamPacketDescription*	inPacketDescriptions)
{
#pragma unused (c)
    rKanal * myself = (rKanal*)inRefCon;
    return ([myself sgAudioCallbackRender:ioFlags 
                    timestamp:inTimeStamp 
                    numPackets:inNumberPackets 
                    buffer:inData
                    packetDescs:inPacketDescriptions]);
}

/*________________________________________________________________________________________
*/

static void 
sgAudioPropListenerCallback(ComponentInstance inComponent, 
                            ComponentPropertyClass inPropClass, 
                            ComponentPropertyID inPropID, 
                            void *inUserData)
{
#pragma unused (inComponent)
    rKanal * myself = (rKanal*)inUserData;
    
    [myself notifyOfChangeInPropClass:inPropClass id:inPropID];
}

/*________________________________________________________________________________________
*/

/*________________________________________________________________________________________
*/

- (void)notifyOfChangeInPropClass:(ComponentPropertyClass)theClass 
            id:(ComponentPropertyID)theID
{
    NSString * notif = nil;
  
    switch (theClass) {
        case kQTPropertyClass_SGAudio:
            switch (theID) {
                case kQTSGAudioPropertyID_DeviceListWithAttributes:
                    notif = SGAudioDeviceListChangedNotification;
                    break;
                    
                case kQTSGAudioPropertyID_StreamFormat:
                    notif = SGAudioOutputStreamFormatChangedNotification;
                    break;
                    
                default:
                    NSLog(@"Unknown SGAudio property (%.4s)", (char*)&theID);
                    break;
            };
            break;
            
        case kQTPropertyClass_SGAudioRecordDevice:
            switch (theID) {
                case kQTSGAudioPropertyID_DeviceAlive:
                    notif = SGAudioRecordDeviceDiedNotification;
                    mDoInitFXUnits = YES;
                    break;
                    
                case kQTSGAudioPropertyID_DeviceHogged:
                    notif = SGAudioRecordDeviceHoggedChangedNotification;
                    break;
                    
                case kQTSGAudioPropertyID_DeviceInUse:
                    notif = SGAudioRecordDeviceInUseChangedNotification;
                    break;
                    
                case kQTSGAudioPropertyID_StreamFormat:
                    notif = SGAudioRecordDeviceStreamFormatChangedNotification;
                    mDoInitFXUnits = YES;
                    break;
                    
                case kQTSGAudioPropertyID_StreamFormatList:
                    notif = SGAudioRecordDeviceStreamFormatListChangedNotification;
                    break;
                    
                case kQTSGAudioPropertyID_InputSelection:
                    notif = SGAudioRecordDeviceInputSelectionNotification;
                    break;
                    
                case kQTSGAudioPropertyID_InputListWithAttributes:
                    notif = SGAudioRecordDeviceInputListChangedNotification;
                    break;
                    
                default:
                    NSLog(@"Unknown SGAudioRecordDevice property (%.4s)", (char*)&theID);
                    break;
            };
            break;
        
        case kQTPropertyClass_SGAudioPreviewDevice:
            switch (theID) {
                case kQTSGAudioPropertyID_DeviceAlive:
                    notif = SGAudioPreviewDeviceDiedNotification;
                    break;
                    
                case kQTSGAudioPropertyID_DeviceHogged:
                    notif = SGAudioPreviewDeviceHoggedChangedNotification;
                    break;
                    
                case kQTSGAudioPropertyID_DeviceInUse:
                    notif = SGAudioPreviewDeviceInUseChangedNotification;
                    break;
                    
                case kQTSGAudioPropertyID_StreamFormat:
                    notif = SGAudioPreviewDeviceStreamFormatChangedNotification;
                    break;
                    
                case kQTSGAudioPropertyID_StreamFormatList:
                    notif = SGAudioPreviewDeviceStreamFormatListChangedNotification;
                    break;
                    
                case kQTSGAudioPropertyID_OutputSelection:
                    notif = SGAudioPreviewDeviceOutputSelectionChangedNotification;
                    break;
                    
                case kQTSGAudioPropertyID_OutputListWithAttributes:
                    notif = SGAudioPreviewDeviceOutputListChangedNotification;
                    break;
                    
                default:
                    NSLog(@"Unknown SGAudioPreviewDevice property (%.4s)", (char*)&theID);
                    break;
            };
            break;
            
        default:
            NSLog(@"[SGAudio] Unknown property class (%.4s), id (%.4s)", (char*)&theClass, (char*)&theID);
            break;
    };
    
    if (notif)
	{
		//NSLog(@"SGAudioRecordDeviceStreamFormatChangedNotification: ");
        [[NSNotificationCenter defaultCenter] postNotificationName:notif object:self];
		}
}

/* ---------------------------------------------------------------------- */

static pascal Boolean
SeqGrabberModalFilterProc (DialogPtr theDialog, const EventRecord *theEvent,
						   short *itemHit, long refCon)
{
	// Ordinarily, if we had multiple windows we cared about, we'd handle
	// updating them in here, but since we don't, we'll just clear out
	// any update events meant for us
	
	Boolean	handled = false;
	
	return (handled);
}

/* ---------------------------------------------------------------------- */

@end
