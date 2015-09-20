#import "rPasswortRequest.h"

@implementation rPasswortRequest

- (IBAction)reportCancel:(id)sender
{
[NameFeld setStringValue:@""];
[PasswortFeld setStringValue:@""];

  [NSApp stopModalWithCode:0];
  [[self window]orderOut:NULL];
  

}
- (id) init
{
    //if ((self = [super init]))
	self = [super initWithWindowNibName:@"RPPasswortRequest"];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
		confirmPasswortDic=[[NSMutableDictionary alloc]initWithCapacity:0];

	return self;
}

- (void) awakeFromNib
{
	NSFont* RecPlayfont;
	RecPlayfont=[NSFont fontWithName:@"Helvetica" size: 24];
	NSColor * RecPlayFarbe=[NSColor cyanColor];
	[LesestudioString setFont: RecPlayfont];
	[LesestudioString setTextColor: RecPlayFarbe];
	NSFont* Titelfont;
	Titelfont=[NSFont fontWithName:@"Helvetica" size: 18];
	NSColor * TitelFarbe=[NSColor grayColor];
	//[TitelString setFont: Titelfont];
	//[TitelString setTextColor: TitelFarbe];
	[PasswortFeld setDelegate:self];
	[[self window]makeFirstResponder:PasswortFeld];
	[SchliessenTaste setKeyEquivalent:@"\r"];
	
}

- (void)setName:(NSString*)derName mitPasswort:(NSData*)dasPasswort
{
	[NameFeld setStringValue:derName];
	confirmPasswort=dasPasswort;
	[confirmPasswortDic removeAllObjects];
	if ([confirmPasswort length])
	{
		[[self window]makeFirstResponder:PasswortFeld];
		
	}
	confirmPasswortOK=NO;
	PasswortFehler=0;
	[PasswortFeld setStringValue:@""];
}

- (IBAction)reportClose:(id)sender
{
	//NSLog(@"PasswortRequest reportClose");
	const char* confirmpw=[[PasswortFeld stringValue] UTF8String];
	NSData* confirmPWData =[NSData dataWithBytes:confirmpw length:strlen(confirmpw)];
	NSString* defaultPasswort=@"homer";
	const char* defaultpw=[defaultPasswort  UTF8String];
	NSData* defaultPWData =[NSData dataWithBytes:defaultpw length:strlen(defaultpw)];
	BOOL istAdmin=[[NameFeld stringValue]isEqualToString:@"Admin"];//Admin darf mit defaultPW einsteigen
	//if([kontrollPWData isEqualToData:confirmPasswort]||[kontrollPWData isEqualToData:defaultPWData])

//	if ([confirmPWData isEqualToData:confirmPasswort]||([confirmPWData isEqualToData:defaultPWData]&&istAdmin))
	if ([confirmPWData isEqualToData:confirmPasswort]||([confirmPWData isEqualToData:defaultPWData]))//richtiges PW oder "homer"
	{
		[NameFeld setStringValue:@""];
		[PasswortFeld setStringValue:@""];

		[NSApp stopModalWithCode:1];
		[[self window]orderOut:NULL];
	}
	else
	{
		if (PasswortFehler<2)
		{
			//NSLog(@"PasswortRequest reportClose  Passwort falsch");
			NSAlert *Warnung = [[NSAlert alloc] init];
			[Warnung addButtonWithTitle:@"OK"];
			[Warnung setMessageText:@"Falsches Passwort"];
			
			NSString* s1=@"Es sind 3 Versuche mšglich";
			NSString* s2=@"Das war Versuch ";
			NSString* InformationString=[NSString stringWithFormat:@"%@\n%@ %d",s1,s2,PasswortFehler+1];
			[Warnung setInformativeText:InformationString];
			[Warnung setAlertStyle:NSWarningAlertStyle];
			
			//[Warnung setIcon:RPImage];
			int antwort=[Warnung runModal];
			
			[PasswortFeld selectText:nil];
			PasswortFehler++;
		}
		else
		{
			[NameFeld setStringValue:@""];
			[PasswortFeld setStringValue:@""];

			[NSApp stopModalWithCode:0];
			[[self window]orderOut:NULL];
			
		}
	}
	
	
}

- (IBAction)reportNeuesPasswort:(id)sender
{

}
@end
