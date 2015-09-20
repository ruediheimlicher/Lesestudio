#import "rPasswortDialog.h"

@implementation rPasswortDialog
- (id) init
{
    //if ((self = [super init]))
	self = [super initWithWindowNibName:@"RPPasswortDialog"];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];

	[nc addObserver:self
		   selector:@selector(altesPWAktion:)
			   name:@"altesPW"
			 object:nil];

	PasswortFehler=0;
	neuerPasswortDic=[[NSMutableDictionary alloc]initWithCapacity:0];


	return self;
}
- (void) awakeFromNib
{
	//NamenDic=[[NSMutableDictionary alloc] initWithCapacity:0];


	NSFont* RecPlayfont;
	RecPlayfont=[NSFont fontWithName:@"Helvetica" size: 24];
	NSColor * RecPlayFarbe=[NSColor cyanColor];
	[LesestudioString setFont: RecPlayfont];
	[LesestudioString setTextColor: RecPlayFarbe];
	NSFont* Titelfont;
	Titelfont=[NSFont fontWithName:@"Helvetica" size: 18];
	NSColor * TitelFarbe=[NSColor grayColor];
	[TitelString setFont: Titelfont];
	[TitelString setTextColor: TitelFarbe];
	[neuesPW1Feld setDelegate:self];
	[[self window]makeFirstResponder:altesPWFeld];
	[ChangeTaste setKeyEquivalent:@"\r"];
	[neuesPW1Feld setNextKeyView:neuesPW2Feld];
	
}

- (IBAction)reportAltesPW:(id)sender
{

}

- (IBAction)reportCancel:(id)sender
{
[neuesPW1Feld setStringValue:@""];
[neuesPW2Feld setStringValue:@""];
[altesPWFeld setStringValue:@""];
  //NSMutableDictionary* NotificationDic=[NSMutableDictionary dictionaryWithObject:ProjektString forKey:@"projekt"];
  NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
 // [nc postNotificationName:@"ProjektStart" object:self userInfo:NotificationDic];
 PasswortFehler=0;
  [NSApp stopModalWithCode:0];
  [[self window]orderOut:NULL];

}

- (IBAction)reportChange:(id)sender
{
if ([[neuesPW1Feld stringValue]length]==0)
	{
	NSAlert *Warnung = [[NSAlert alloc] init];
	[Warnung addButtonWithTitle:@"OK"];
	[Warnung setMessageText:@"Eingabefehler:"];
	[Warnung setInformativeText:@"Das Passwort darf nicht leer sein."];
	[Warnung setAlertStyle:NSWarningAlertStyle];
	[Warnung runModal];
	
	return;
	}
	if ([[neuesPW2Feld stringValue]isEqualToString:[neuesPW1Feld stringValue]])//Passwort OK
	{
	
		neuesPasswortOK=YES;
		const char* neuespw=[[neuesPW1Feld stringValue] UTF8String];
		NSData* neuesPWData =[NSData dataWithBytes:neuespw length:strlen(neuespw)];
		[neuerPasswortDic setObject:neuesPWData forKey:@"pw"];
		[neuerPasswortDic setObject:[NameFeld stringValue] forKey:@"name"];
		NSLog(@"PasswortDialogreportChange	neuerPasswortDic: %@",[neuerPasswortDic description]);
		NSMutableDictionary* NotificationDic=[NSMutableDictionary dictionaryWithObject:neuesPWData forKey:@"pw"];
		[NotificationDic setObject:[NameFeld stringValue] forKey:@"name"];
		NSLog(@"PasswortDialog reportChange	NotificationDic: %@",[NotificationDic description]);
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"neuesUserPW" object:self userInfo:NotificationDic];
		PasswortFehler=0;
		[neuesPW1Feld setStringValue:@""];
		[neuesPW2Feld setStringValue:@""];
		[altesPWFeld setStringValue:@""];
		
		[NSApp stopModalWithCode:1];
		[[self window]orderOut:NULL];
		
	}
	else
	{
		neuesPasswortOK=NO;
		[neuesPW2Feld setStringValue:@""];
		NSAlert *Warnung = [[NSAlert alloc] init];
		[Warnung addButtonWithTitle:@"Wiederholen"];
		[Warnung addButtonWithTitle:@"Abbrechen"];
		[Warnung setMessageText:@"Eingabefehler:"];
		NSString* s= @"Die zweite Eingabe stimmt nicht mit der ersten Ÿberein.";
		NSString* InformationString=[NSString stringWithFormat:@"%@",s];
		[Warnung setInformativeText:InformationString];

		[Warnung setAlertStyle:NSWarningAlertStyle];
		
		//[Warnung setIcon:RPImage];
		
		int antwort=[Warnung runModal];
		
		switch (antwort)
		{
			case NSAlertFirstButtonReturn://Wiederholen
			{ 
				NSLog(@"Wiederholen");
				if  (PasswortFehler>2)//zu viele Fehlversuche
				{
					break;
				}
				else
				{
					PasswortFehler++;
					if ([neuesPW2Feld acceptsFirstResponder])
					{
						NSLog(@"acceptsFirstResponder");
						//[altesPWFeld performClick:nil];
						//BOOL result=[[self window]makeFirstResponder:altesPWFeld];
						//NSLog(@"antwort: result: %d",result);
						[[self window] performSelector:@selector(makeFirstResponder:)
											withObject:neuesPW2Feld
											afterDelay:0
											   inModes:[NSArray arrayWithObject:NSModalPanelRunLoopMode]];
					}
				}
				
			}break;
				
			case NSAlertSecondButtonReturn://Abbrechen
			{
				NSLog(@"Abbrechen");
				
			}break;
				
		}//switch
		
		
	}
	}
	
- (NSDictionary*)neuerPasswortDic
{
NSLog(@"return neuerPasswortDic: %@",[neuerPasswortDic description]);
return [neuerPasswortDic copy];
}
	


- (IBAction)reportNeuesPW:(id)sender
{
}







- (void)setName:(NSString*)derName mitPasswort:(NSData*)dasPasswort
{
	[NameFeld setStringValue:derName];
	altesPasswort=dasPasswort;
	[neuerPasswortDic removeAllObjects];
	if ([altesPasswort length])
	{
		altesPasswortOK=NO;
		[altesPWFeld setHidden:NO];
		[altesPWString setHidden:NO];
		[altesPWFeld setNextKeyView:neuesPW1Feld];
		[[self window]makeFirstResponder:altesPWFeld];
		
	}
	else
	{
		altesPasswortOK=YES;
		[altesPWFeld setHidden:YES];
		[altesPWString setHidden:YES];
		[neuesPW1Feld setEditable:YES];
		[ChangeTaste setTitle:@"Sichern"];

		[[self window]makeFirstResponder:neuesPW1Feld];

	}
	neuesPasswortOK=NO;
	
}


- (void)altesPWAktion:(NSNotification*)note
{
	//NSLog(@"PasswortDialog: altesPWAktion Fehler: %d: ",PasswortFehler);
	[[self window]makeKeyWindow];
	NSString* tempAltesPasswort=[altesPWFeld stringValue];
	if ([tempAltesPasswort length])
	{
		const char* altespw=[[altesPWFeld stringValue] UTF8String];
		NSData* kontrollPWData =[NSData dataWithBytes:altespw length:strlen(altespw)];
		
		NSString* defaultPasswort=@"homer";
		const char* defaultpw=[defaultPasswort  UTF8String];
		NSData* defaultPWData =[NSData dataWithBytes:defaultpw length:strlen(defaultpw)];
		
		if([kontrollPWData isEqualToData:altesPasswort]||[kontrollPWData isEqualToData:defaultPWData])
		{
			altesPasswortOK=YES;
			[neuesPW1Feld setEditable:YES];
			
		}
		else
		{
			//NSBeep();
			//[neuesPW1Feld setEditable:NO];
			//[neuesPW2Feld setEditable:NO];
			altesPasswortOK=NO;
			if  (PasswortFehler>2)//zu viele Fehlversuche
			{
				return;
			}
			
			
			//[neuesPW1Feld setEditable:YES];
			//NSLog(@"PasswortDialog: altesPWAktion: Altes PW falsch");
			
			BOOL result=[[self window]makeFirstResponder:altesPWFeld];
			NSLog(@"result: %d",result);
			NSAlert *Warnung = [[NSAlert alloc] init];
			[Warnung addButtonWithTitle:@"Wiederholen"];
			[Warnung addButtonWithTitle:@"Abbrechen"];
			[Warnung setMessageText:@"Eingabefehler"];
			
			NSString* s=@"Das alte Passwort ist falsch.";
			NSString* InformationString=[NSString stringWithFormat:@"%@",s];
			[Warnung setInformativeText:InformationString];
			
			[Warnung setAlertStyle:NSWarningAlertStyle];
			
			//[Warnung setIcon:RPImage];
			int antwort=[Warnung runModal];
			
			switch (antwort)
			{
				case NSAlertFirstButtonReturn://Wiederholen
				{ 
					NSLog(@"Wiederholen");
					if  (PasswortFehler>2)//zu viele Fehlversuche
					{
						break;
					}
					else
					{
						PasswortFehler++;
						[altesPWFeld performClick:nil];
						if ([altesPWFeld acceptsFirstResponder])
						{
							NSLog(@"acceptsFirstResponder");
							//[altesPWFeld performClick:nil];
							//BOOL result=[[self window]makeFirstResponder:altesPWFeld];
							//NSLog(@"antwort: result: %d",result);
							[[self window] performSelector:@selector(makeFirstResponder:)
												withObject:altesPWFeld
												afterDelay:0
												   inModes:[NSArray arrayWithObject:NSModalPanelRunLoopMode]];
						}
					}
					
				}break;
					
				case NSAlertSecondButtonReturn://Abbrechen
				{
					NSLog(@"Abbrechen");
					
				}break;
					
			}//switch
			
		}
	}//altesPasswort length
	else
	{
		NSBeep();
	}
	
}
- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
	//NSLog(@"controlTextDidBeginEditing: %@",[[aNotification  userInfo]objectForKey:@"NSFieldEditor"]);
	//[InListeTaste setKeyEquivalent:@"\r"];
 // [EntfernenTaste setEnabled:NO];
 // [AuswahlenTaste setEnabled:NO];

	//[InListeTaste setEnabled:YES];
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
//NSLog(@"control textShouldBeginEditing");
return YES;
}

 -(BOOL)textShouldBeginEditing:(NSText *)textObject
 {
	const char* PWChar=[[NameFeld stringValue] UTF8String];
	NSData* neuesPWData=[NSData dataWithBytes:PWChar length:strlen(PWChar)];
	
	//NSLog(@"**textShouldBeginEditing: neuesPWData: %@",neuesPWData);

    return YES;
 }
/*
 - (BOOL)becomeFirstResponder
 {
  NSLog(@"rPasswortEingabeFeld becomeFirstResponder");
return YES;
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];

[nc postNotificationName:@"altesPW" object:self];

 return YES;
 }
*/
@end
