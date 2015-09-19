#import "rPasswortListe.h"

@implementation rPasswortListe
- (id) init
{
    //if ((self = [super init]))
	self = [super initWithWindowNibName:@"RPPasswortListe"];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];

	/*[nc addObserver:self
		   selector:@selector(EnterKeyNotifikationAktion:)
			   name:@"EnterTaste"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(EingabeChangeNotificationAktion:)
			   name:@"NSTextDidChangeNotification"
			 object:EingabeFeld];
	*/
	return self;
}
- (void) awakeFromNib
{
	PasswortDic=[[NSMutableDictionary alloc] initWithCapacity:0];
	PasswortArray=[[NSMutableArray alloc] initWithCapacity:0];
	
	[PasswortTable setDataSource:self];
	[PasswortTable setDelegate: self];
	NSFont* RecPlayfont;
	RecPlayfont=[NSFont fontWithName:@"Helvetica" size: 32];
	NSColor * RecPlayFarbe=[NSColor grayColor];
	[LesestudioString setFont: RecPlayfont];
	[LesestudioString setTextColor: RecPlayFarbe];
	NSFont* Titelfont;
	Titelfont=[NSFont fontWithName:@"Helvetica" size: 18];
	NSColor * TitelFarbe=[NSColor grayColor];
	[TitelString setFont: Titelfont];
	[TitelString setTextColor: TitelFarbe];
	
}

- (IBAction)reportBearbeiten:(id)sender
{
NSLog(@"reportBearbeiten: state: %d",[sender state]);
if ([sender state])
{
[BearbeitenTaste setTitle:NSLocalizedString(@"Save Password",@"Passwort sichern")];
[SchliessenTaste setEnabled:NO];
}
else
{
[BearbeitenTaste setTitle:NSLocalizedString(@"Change Password",@"Passwort bearbeiten")];
[SchliessenTaste setEnabled:YES];
[[self window]makeFirstResponder:PasswortTable];
}
[[PasswortTable tableColumnWithIdentifier:@"passwort"]setEditable:[sender state]];
[PasswortTable reloadData];
//[[self window]makeFirstResponder:PasswortTable];
}

- (IBAction)reportCancel:(id)sender
{
[PasswortTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0]byExtendingSelection:NO];
[[PasswortTable tableColumnWithIdentifier:@"passwort"]setEditable:NO];
[BearbeitenTaste setTitle:NSLocalizedString(@"Change Password",@"Passwort bearbeiten")];
[SchliessenTaste setEnabled:YES];
[NSApp stopModalWithCode:0];
[[self window]orderOut:NULL];

}

- (IBAction)reportClose:(id)sender
{
	NSArray* tempPWArray=[PasswortArray copy];
	
	[PasswortArray removeAllObjects];
	NSEnumerator* PasswortEnum=[tempPWArray objectEnumerator];
	id einDic;
	while (einDic=[PasswortEnum nextObject])
	{
		NSMutableDictionary* tempDictionary=[[NSMutableDictionary alloc]initWithCapacity:0];
		[tempDictionary setObject:[einDic objectForKey:@"name"] forKey:@"name"];
		
		const char* ch=[[einDic objectForKey:@"passwort"] UTF8String];
		NSData* tempPWData=[NSData dataWithBytes:ch length:strlen(ch)];
		
		[tempDictionary setObject:tempPWData forKey:@"pw"];
		[PasswortArray addObject:tempDictionary];
	}//while
	
	NSLog(@"PasswortArray nach change:PasswortArray: %@ ",[PasswortArray description]);
	
	[[PasswortTable tableColumnWithIdentifier:@"passwort"]setEditable:NO];
	[PasswortTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0]byExtendingSelection:NO];
	
	[NSApp stopModalWithCode:1];
	[[self window]orderOut:NULL];
	
}

- (void)setPasswortArray:(NSArray*)derArray
{
	[PasswortArray removeAllObjects];
	
	NSEnumerator* PasswortEnum=[derArray objectEnumerator];
	id einDic;
	while (einDic=[PasswortEnum nextObject])
	{
		NSMutableDictionary* tempDictionary=[[NSMutableDictionary alloc]initWithCapacity:0];
		[tempDictionary setObject:[einDic objectForKey:@"name"] forKey:@"name"];
		NSString* tempPWString= [[NSString alloc] initWithData: [einDic objectForKey:@"pw"] encoding: NSMacOSRomanStringEncoding];
		//NSLog(@"**setPasswortArray: tempPWString nach data: %@",tempPWString);
		[tempDictionary setObject:tempPWString forKey:@"passwort"];
		[PasswortArray addObject:tempDictionary];
		
	}//while
	
	[PasswortTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0]byExtendingSelection:NO];
	[[self window]makeFirstResponder:PasswortTable];
	
	//NSLog(@"setPasswortArray nach set:PasswortArray: %@  ",[PasswortArray description]);
	[PasswortTable reloadData];
}

- (NSArray*)PasswortArray
{
	
	return PasswortArray;
}

#pragma mark -
#pragma mark ProjectTable delegate:

- (void)EingabeChangeNotificationAktion:(NSNotification*)note
{
	
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
	//NSLog(@"controlTextDidBeginEditing: %@",[[aNotification  userInfo]objectForKey:@"NSFieldEditor"]);
	//[[self window]makeFirstResponder:InListeTaste];
	//[InListeTaste setKeyEquivalent:@"\r"];
	//[InListeTaste setEnabled:YES];
}
#pragma mark -
#pragma mark ProjectTable Data Source:

- (long)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [PasswortArray count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(long)rowIndex
{
//NSLog(@"objectValueForTableColumn: %@",[PasswortArray description]);
   NSDictionary* einPasswortDic;

	if (rowIndex<[PasswortArray count])
	  {
		NS_DURING
			einPasswortDic = [PasswortArray objectAtIndex: rowIndex];
			//NSLog(@"einPasswortDic: %@",[einPasswortDic description]);

		NS_HANDLER
			if ([[localException name] isEqual: @"NSRangeException"])
			  {
				return nil;
			  }
			else [localException raise];
		NS_ENDHANDLER
	  }
return [einPasswortDic objectForKey:[aTableColumn identifier]];
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex
{
    NSMutableDictionary* einPasswortDic;
    if (rowIndex<[PasswortArray count])
	  {
		einPasswortDic=[PasswortArray objectAtIndex:rowIndex];
		[einPasswortDic setObject:anObject forKey:[aTableColumn identifier]];

	  }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row
{
	{
		//NSLog(@"shouldSelectRow im Bereich: row %d",row);
		//[HomeKnopf setState:0];
		//[Kopierentaste setKeyEquivalent:@""];
		//[Kopierentaste setEnabled:YES];
		//[OKKnopf setKeyEquivalent:@"\r"];
		
	}
	return YES;
}
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ([PasswortTable numberOfSelectedRows]==0)
	  {
		//[OKKnopf setEnabled:NO];
		//[OKKnopf setKeyEquivalent:@""];
		//[HomeKnopf setKeyEquivalent:@"\r"];
	  }
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSFont* Tablefont;
	Tablefont=[NSFont fontWithName:@"Helvetica" size: 14];
	[cell setFont:Tablefont];
	if ([[tableColumn identifier] isEqualToString:@"namen"])
	  {
		//NSColor * SuchenFarbe=[NSColor orangeColor];
		//[cell setTextColor:SuchenFarbe];
	  }
	else
	  {
		NSColor * TextFarbe=[NSColor blackColor];
		//[cell setTextColor:TextFarbe];
		
	  }
}


@end
