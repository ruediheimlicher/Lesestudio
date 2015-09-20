//
//  rGrabber.m
//  RecPlayII
//
//  Created by Sysadmin on 03.12.05.
//  Copyright 2005 Ruedi Heimlicher. All rights reserved.
//

#import "rGrabber.h"
#import "rKanal.h"


NSString * SeqGrabChannelRemovedNotification = @"SeqGrabChannelRemovedNotification";
NSString * SeqGrabChannelAddedNotification   = @"SeqGrabChannelAddedNotification";
NSString * SeqGrabChannelKey                 = @"SeqGrabChannelKey";
static pascal Boolean
SeqGrabberModalFilterProc (DialogPtr theDialog, const EventRecord *theEvent,
						   short *itemHit, long refCon);

@implementation rGrabber

+ (void)initialize
{
	EnterMovies();
}

- (id)init
{
	OSStatus err=noErr;
	Level=0;
	ChannelOK=NO;
	LevelArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	self=[super init];
	err=OpenADefaultComponent(SeqGrabComponentType,0,&Grabber);
	if (err)
	{
		[self release];
		return nil;
	}
	err=SGInitialize(Grabber);
	if (err)
	{
		[self release];
		return nil;
	}
	
	/*
	UserData	ud = NULL;
	Handle		hud = NewHandle(0);
	//NSData *	data = nil;
	
	err=SGGetSettings(Grabber, &ud, 0);
	
	err=PutUserDataIntoHandle(ud, hud);

	GrabberDaten = [NSData dataWithBytes:*hud length:GetHandleSize(hud)];//Bisherige Daten, gespeichert 
	NSLog(@"init: GetSettings: %@",[GrabberDaten description]);
	*/
	
	float dauer=3600;
	err=SGSetMaximumRecordTime(Grabber,(UInt32)((dauer*60)+.5));
	if (err)
	{
		[self release];
		return nil;
	}

	SoundKanalArray=[[NSMutableArray alloc]initWithCapacity:0];
	[self startTimer];
	NSTimer* delayTimer=[[NSTimer scheduledTimerWithTimeInterval:0.05 
													 target:self 
												   selector:@selector(startLevelTimer:) 
												   userInfo:nil 
													repeats:NO]retain];

	RecordingOK=NO;
	return self;
}

- (NSData*)GrabberDaten
{
return GrabberDaten;
}

- (OSErr)restoreGrabberDaten:(NSData*)dieDaten
{
	//Beim Start gespeicherte Daten werden wieder gesetzt
	OSStatus	err = noErr;
	UserData	ud = NULL;
	Handle		hud = NULL;
	short		idx;
	SGChannel	c;
	OSType		type;
    UserData    savedUD = NULL;
    
    err=SGGetSettings(Grabber, &savedUD, 0) ;//aktuelle Daten sichern
	if (err)
	{
		return err;
	}
	hud = NewHandle([dieDaten length]);
	memcpy(*hud, [dieDaten bytes], [dieDaten length]);
	err= NewUserDataFromHandle(hud, &ud);
	if (err)
	{
		return err;
	}
	
	err= SGSetSettings(Grabber, ud, 0);
	
	return err;
}

- (void)setMaster:(id)derMaster
{
	[derMaster retain];
	[Master release];

	Master=derMaster;
}

- (void)dealloc
{
	NSLog(@"Grabber dealloc");
	CloseComponent(Grabber);
	[AufnahmePfad release];
	[SicherAufnahmePfad release];
	[super dealloc];
}

- (NSArray*)SoundKanalArray
{
	return SoundKanalArray;
}

- (OSStatus)addKanalZuArray:(rKanal*)derKanal
{
	NSString* summString=[derKanal summaryString];
	//NSLog(@"Kanal: summString: %@",summString);
	
	NSArray* DeviceListe=[derKanal deviceList];
	if (DeviceListe)
	{
		//NSLog(@"Kanal: DeviceListe: %s",[DeviceListe objectAtIndex:0]);
	}
	else
	{
		//NSLog(@"Kanal: keine DeviceListe");
	}
	
	
	
	if (![SoundKanalArray containsObject:derKanal])
	{
		[SoundKanalArray addObject:derKanal];
		ChannelOK=YES;
	}
	else
	{
		ChannelOK=NO;
	}
	return 0;
}

- (OSErr)prepare
{
OSErr err=noErr;
if (Grabber)
{
	NSTimeInterval delta;
	NSDate* Startzeit=[NSDate date];

// 9.5.08	err=SGPrepare(Grabber,true, false);
	err=SGPrepare(Grabber,false, true);
	NSLog(@"Prepare OK: %d",err);
	delta=[[NSDate date]timeIntervalSinceDate:Startzeit];
	NSLog(@"SGPrepare delta: %f",delta);

	//SGStartPreview(Grabber);
}
return err;
}



- (OSStatus)removeKanal
{
	
}

- (NSArray*)getSoundKanalArray
{
return SoundKanalArray;
}

- (SeqGrabComponent)Grabber
{
	return Grabber;
}


- (BOOL)setAufnahmePfad:(NSString*)derAufnahmePfad flags:(long)flags
{
	OSStatus err=0;
	Handle dataRef=NULL;
	OSType dataRefType=0;
	
	if (derAufnahmePfad)
	{
	err=QTNewDataReferenceFromFullPathCFString((CFStringRef)derAufnahmePfad,
					(UInt32)kQTNativeDefaultPathStyle,
					0,&dataRef,&dataRefType);
	}//if
	
	[AufnahmePfad release];
	AufnahmePfad=[derAufnahmePfad retain];
	AufnahmeFlags=flags;
	
	if (!(flags & seqGrabDontMakeMovie))
	{
		if (!(flags & seqGrabDontPreAllocateFileSize)&& !(flags & seqGrabAppendToFile))
		{
			fclose(fopen([AufnahmePfad UTF8String],"w"));
			flags |=seqGrabAppendToFile;
		}
	}
	err=SGSetDataRef(Grabber,dataRef,dataRefType,flags);
	DisposeHandle(dataRef);
	return (err==0);
}


- (OSStatus)setGrabberSettings:(NSData*)dieDaten
{
	OSStatus	err = noErr;
	UserData	ud = NULL;
	Handle		hud = NULL;
	short		idx;
	SGChannel	c;
	OSType		type;
    UserData    savedUD = NULL;
	
    	
	
	//NSLog(@"Grabber setGrabberSettings: l: %d\n%@\n",[dieDaten length],[dieDaten description]);

    err=SGGetSettings(Grabber, &savedUD, 0);
	if (err)goto bail;
	
	hud = NewHandleClear([dieDaten length]);
	memcpy(*hud, [dieDaten bytes], [dieDaten length]);
	err=NewUserDataFromHandle(hud, &ud);
//	NSLog(@"Grabber setGrabberSettings: NewUserDataFromHandle: length: %d  hud: size: %d\n",[dieDaten length],GetHandleSize(hud));
//	NSLog(@"Grabber setGrabberSettings Start: Anzahl Kanaele: %d\n",[SoundKanalArray count]);
	if (err)
	{
		NSLog(@"NewUserDataFromHandle: err: %ld",err);
		goto bail;
	}
	
	// before setting settings, remove all channel objects,
	// since the settings will have new channel objects.
    while ([SoundKanalArray count])
    {
        rKanal * chan = [[SoundKanalArray lastObject] retain];
        [SoundKanalArray removeLastObject];
        [chan release];
    }
	
	err=SGSetSettings(Grabber, ud, 0);
	if (err)
	{
	NSLog(@"SGSetSettings: err: %ld",err);
	goto bail;
	}
	    
    // iterate through all the channels and set their refcons to 0 (clearing out any
    // SGChan * object associations they may have had from previous runs)
    idx = 0;
    while (noErr == SGGetIndChannel(Grabber, ++idx, &c, &type) )
    {
        SGSetChannelRefCon(c, 0);
    }
	
	// now iterate through mSeqGrab's channel components and make
	// SGChan wrappers for each.  Our implementation uses the SGChannel 
	// RefCon as a pointer to SGChan * object pointer, so if the channel
	//  refcon is non NULL, we don't need to make a wrapper for it
startOver:
	idx = 0;
	while ( noErr == SGGetIndChannel(Grabber, ++idx, &c, &type) )
	{
		long refCon;
        SGGetChannelRefCon(c, &refCon);
		
		switch (type)
		{
				
			case SGAudioMediaType:
				if (refCon == 0)
                {
					rKanal * kanal = [[rKanal alloc] initWithSeqGrab:self channelComponent:c];
					[self addKanalZuArray:kanal];
                    [kanal release];
                }
				break;
				
				
			default:
				NSLog(@"[Grabber setSettings:] encountered an "
                        "unrecognized chan type - \"%.4s\"", (char*)&type);
						err=1;
		}
	}
	
bail:
    if (err)
    {
		NSLog(@"SetGrabberSettings: Fehler: %ld",err);
        SGSetSettings(Grabber, savedUD, 0);
    }
    DisposeUserData(savedUD);
	DisposeHandle(hud);
	DisposeUserData(ud);
	//NSLog(@"Grabber setGrabberSettings Schluss:Anzahl Kanaele: %d\n",[SoundKanalArray count]);
	return err;
}

- (NSData *)GrabberSettings
{
	//Settings des Grabbers als NSData
	OSStatus	err = noErr;
	UserData	ud = NULL;
	Handle		hud = NewHandle(0);
	NSData *	data = nil;
	
	err= SGGetSettings(Grabber, &ud, 0);
	if (err)
	{
		DisposeUserData(ud);
		DisposeHandle(hud);
		return data;
	}

	err=PutUserDataIntoHandle(ud, hud);
	NSLog(@"GrabberSettings: Handle: %ld  err: %ld",GetHandleSize(hud),err);

		if (err)
	{
		NSLog(@"Nach PutUserDataIntoHandle: err: %ld",err);
		DisposeUserData(ud);
		DisposeHandle(hud);
		return data;
	}
	
	data = [NSData dataWithBytes:*hud length:GetHandleSize(hud)];
	//NSLog(@"Grabber GrabberSettings: l: %d\n%@\n",[data length],[data description]);
	DisposeUserData(ud);
	DisposeHandle(hud);
	return data;
}



- (OSStatus)preview
{
	ComponentResult err=0;
	//18.3.
	SGPrepare(Grabber, true, false);

	err=SGStartPreview(Grabber);
	return err;
}


- (OSStatus)startRecord
{
	NSTimeInterval delta;
	NSDate* Startzeit=[NSDate date];
	OSErr err=0;
	if (RecordingOK)
	return err;
	Idletakt=0;
	RecordingOK=NO;
	delta=[[NSDate date]timeIntervalSinceDate:Startzeit];
	//NSLog(@"Intervall 1: %f",delta);
	err=SGStartRecord(Grabber);
	delta=[[NSDate date]timeIntervalSinceDate:Startzeit];
	//NSLog(@"Intervall 2: %f",delta);

	//NSLog(@"startRecord: err: %d",err);
	if (!err)
	{
	RecordingOK=YES;
	}
	
	return err;

}


- (OSStatus)stopRecord
{
OSErr err=0;
	if (!RecordingOK)
	return err;
	err=SGStop(Grabber);
	RecordingOK=NO;
	//NSLog(@"LevelArray: %@",[LevelArray description]);
	return err;
}

- (BOOL)isRecording
{
	return RecordingOK;
}


- (BOOL)isPreviewing
{
	
}

- (void)startTimer
{
	long idlesProSekinde=10;
	NSTimer* t=[[NSTimer scheduledTimerWithTimeInterval:0.05 
												 target:self 
											   selector:@selector(IdleTimer:) 
											   userInfo:nil repeats:YES] retain];

}


- (void)IdleTimer:(NSTimer*)timer
{
	OSErr err=[self Idlefunktion];
	if (err)
	{
		[timer invalidate];
		
		
		NSAlert *Warnung = [[[NSAlert alloc] init] autorelease];
						  [Warnung addButtonWithTitle:@"OK"];
						  
						  [Warnung setMessageText:NSLocalizedString(@"Record",@"Aufnehmen:")];
						  NSString* i1=NSLocalizedString(@"An error occurred while recording. Try again.",@"Beim Aufnehmen ist ein Fehler aufgetreten.Versuche es noch einmal");
						  NSString* i2=NSLocalizedString(@"Maybe the allowed recording time was reached",@"Möglicherweise wurde die erlaubte Aufnahmezeit überschritten");
						  [Warnung setInformativeText:[NSString stringWithFormat:@"%@n%@",i1,i2]];						  
						  [Warnung setAlertStyle:NSWarningAlertStyle];
						  int IdleOK=[Warnung runModal];
						  NSLog(@"IdleTimer: Aufnahme abgebrochen: Fehler: %d",err);
						  [self stopRecord];
	}
}

- (void)LevelTimer:(NSTimer*)timer
{
	Level=0;
	if ([SoundKanalArray count])
	{
		rKanal* tempKanal=[SoundKanalArray objectAtIndex:0];
		
		if (tempKanal && RecordingOK)
		{
			Level=[tempKanal AufnahmeLevel];
			if (Level>200)
			{
				NSLog(@"Level: %f  %d",Level,(int)Level);
			}
		}
	}//if count
	if (Master)
	{
		[Master setLevel:(int)Level];
	}
	
}

- (void)startLevelTimer:(NSTimer*)derTimer
{
	NSTimer* t=[[NSTimer scheduledTimerWithTimeInterval:0.1 
												 target:self 
											   selector:@selector(LevelTimer:) 
											   userInfo:nil 
												repeats:YES] retain];
	

}

- (OSStatus)Idlefunktion
{
	OSErr err=0;
	//NSLog(@"idle");
	if (Grabber)
	{	
		
		if(RecordingOK)
		{
			err=SGIdle(Grabber);		
			if (err)
			{
			NSLog(@"err bei SGIdle: %d",err);
				}	
		}
		else
		{
			Level=0;
		}
	}
	else
	{
		Level=0;
	}
	return err;
}

- (OSErr)GrabberSchliessen
{
	OSErr err=0;
	
	NSEnumerator* KanalEnum=[SoundKanalArray objectEnumerator];
	id einKanal;
	int KanalIndex=0;
	while (einKanal=[KanalEnum nextObject])
	{
		//NSLog(@"GrabberSchliessen KanalIndex: %d",KanalIndex);
		SGDisposeChannel(Grabber, [einKanal SoundKanal]);
		KanalIndex++;
		CloseComponent(Grabber);
	}
	
	
	return err;
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
