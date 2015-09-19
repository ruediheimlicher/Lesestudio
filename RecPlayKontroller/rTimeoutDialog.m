#import "rTimeoutDialog.h"

@implementation rTimeoutDialog
- (id) init
{
    //if ((self = [super init]))
	self = [super initWithWindowNibName:@"RPTimeoutDialog"];
	
	return self;
}

- (void) awakeFromNib
{
	NSFont* RecPlayfont;
	RecPlayfont=[NSFont fontWithName:@"Helvetica" size: 32];
	NSColor * RecPlayFarbe=[NSColor grayColor];
	[LesestudioString setFont: RecPlayfont];
	[LesestudioString setTextColor: RecPlayFarbe];
	//[StartFeld setFont: RecPlayfont];
	NSFont* Titelfont;
	//[StartFeld setTextColor: RecPlayFarbe];
	Titelfont=[NSFont fontWithName:@"Helvetica" size: 18];
	NSColor * TitelFarbe=[NSColor grayColor];
	[TitelString setFont: Titelfont];
	[TitelString setTextColor: TitelFarbe];
	TimeoutCount=0;
}

- (void)setText:(NSString*)derTextString
{
//NSLog(@"TimeoutDialog: derTextString: %@",derTextString);
[StartFeld setStringValue:derTextString];
//[StartFeld setStringValue:@"Hallo"];
}

- (void)setDialogTimer:(int)dieWarteZeit
{
	TimeoutCount=dieWarteZeit;
	if ([TimeoutDialogTimer isValid])
	{
	[TimeoutDialogTimer invalidate];
	}
	TimeoutDialogTimer=[NSTimer scheduledTimerWithTimeInterval:1.0
												   target:self 
												 selector:@selector(TimeoutDialogFunktion:) 
												 userInfo:NULL
												  repeats:YES];
//	[[NSRunLoop currentRunLoop] addTimer: TimeoutDialogTimer forMode:NSModalPanelRunLoopMode];  
}


- (void)TimeoutDialogFunktion:(NSTimer*)timer
{
	if (TimeoutCount&&[TimeoutDialogTimer isValid])
	{
		//NSLog(@"TimeoutDialog: TimeoutCount: %d",TimeoutCount);
		TimeoutCount--;
		[self setZeit:TimeoutCount];
	}
	else
	{
		[TimeoutDialogTimer invalidate];
		
		NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[NotificationDic setObject:[NSNumber numberWithInt:2] forKey:@"abmelden"];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"timeout" object:self userInfo:NotificationDic];
		NSLog(@"TimeoutDialogTimer invalidate: NotificationDic: %@",[NotificationDic description]);
		[NSApp stopModalWithCode:2];
		[[self window]orderOut:NULL];
		//NSLog(@"nach OrderOut");
	}
}

- (void)setZeit:(int)dieZeit
{
//NSLog(@"TimeoutDialog: dieZeit: %d",dieZeit);
[Zeitfeld setIntValue:dieZeit];
//[Zeitfeld setStringValue:@"Hallo"];
}

- (IBAction)reportAbmelden:(id)sender
{
[TimeoutDialogTimer invalidate];
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"abmelden"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"timeout" object:self userInfo:NotificationDic];

//	[NSApp stopModalWithCode:1];
	[[self window]orderOut:NULL];

}

- (IBAction)reportUnterbrechen:(id)sender
{
[TimeoutDialogTimer invalidate];
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:[NSNumber numberWithInt:0] forKey:@"abmelden"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"timeout" object:self userInfo:NotificationDic];

//	[NSApp stopModalWithCode:2];
	[[self window]orderOut:NULL];

}

- (void)stopTimeoutDialogTimer:(id)sender
{
	[TimeoutDialogTimer invalidate];
	[[self window]orderOut:NULL];

}

@end
