#import "rProjektListePanel.h"

@implementation rProjektListePanel

- (id) init
{
   // ((self = [super init]));;
	
	self = [super initWithWindowNibName:@"RPProjektPanel"];
	{
		ProjektArray=[[NSMutableArray alloc] initWithCapacity: 0];
	}
	
	ProjektPfad=[NSString string];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(EnterKeyNotifikationAktion:)
			   name:@"EnterTaste"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(EingabeChangeNotificationAktion:)
			   name:@"NSTextDidChangeNotification"
			 object:EingabeFeld];
	
	return self;
}

- (void) awakeFromNib
{
	ProjektDic=[[NSMutableDictionary alloc] initWithCapacity:0];
	ProjektArray=[[NSMutableArray alloc] initWithCapacity:0];
	
	[ProjektTable setDataSource:self];
	[ProjektTable setDelegate: self];
	NSFont* RecPlayfont;
	RecPlayfont=[NSFont fontWithName:@"Helvetica" size: 36];
	NSColor * RecPlayFarbe=[NSColor whiteColor];
	[LesestudioString setFont: RecPlayfont];
	[LesestudioString setTextColor: RecPlayFarbe];
	[StartString setFont: RecPlayfont];
	NSFont* Titelfont;
	[StartString setTextColor: RecPlayFarbe];
	Titelfont=[NSFont fontWithName:@"Helvetica" size: 18];
	NSColor * TitelFarbe=[NSColor grayColor];
	[TitelString setFont: Titelfont];
	[TitelString setTextColor: TitelFarbe];
	[EingabeFeld setDelegate:self];
	
}

- (void)EnterKeyNotifikationAktion:(NSNotification*)note
{
	//NSLog(@"Projektliste    EnterKeyNotifikationAktion: note: %@",[note object]);
	NSString* Quelle=[[note object]description];
	//NSLog(@"EnterKeyNotifikationAktion: Quelle: %@",Quelle);
	BOOL erfolg;
	[self reportNeuesProjekt:NULL];
	
	
	
}

- (NSPanel*)window
{
	return window;
}

- (int) anzVolumes
{
	return [ProjektArray count];
}

- (IBAction)neueZeile:(id)sender
{
	NSString* neueZeileString=@"neues Projekt:";
	NSMutableDictionary* neuesProjektDic=[NSMutableDictionary dictionaryWithObject:neueZeileString forKey:@"projekt"];
	[neuesProjektDic setObject: [NSNumber numberWithInt:1] forKey:@"OK"];
	[ProjektArray addObject: neuesProjektDic];
	[ProjektTable reloadData];
	[[[ProjektTable tableColumnWithIdentifier:@"projekt"]dataCellForRow:0]setPlaceholderString:@"projekt"];
	//NSString* s=[[ProjektTable tableColumnWithIdentifier:@"projekt"]dataCellForRow:0]selectAll:NULL];
	int n=[ProjektTable columnWithIdentifier:@"projekt"];
	//NSLog(@"n: %d %@",n ,	s);
	
}

- (IBAction)reportCancel:(id)sender
{
	NSString* ProjektString=[NSString string];
	NSMutableDictionary* NotificationDic=[NSMutableDictionary dictionaryWithObject:ProjektString forKey:@"projekt"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"ProjektWahl" object:self userInfo:NotificationDic];
	[NSApp stopModalWithCode:0];
}

- (IBAction)reportClose:(id)sender
{
	int ProjektIndex=[ProjektTable selectedRow];
	if (ProjektIndex>=0)
	  {
		NSString* ProjektString=[[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"projekt"];
		[[self window]makeFirstResponder:ProjektTable];
		NSMutableDictionary* NotificationDic=[NSMutableDictionary dictionaryWithObject:ProjektString forKey:@"projekt"];
		[NotificationDic setObject:ProjektArray forKey:@"projektarray"];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"ProjektWahl" object:self userInfo:NotificationDic];
	  }//if ProjektIndex
	[NSApp stopModalWithCode:1];
	[[self window] orderOut:NULL];
}

- (IBAction)reportNeuesProjekt:(id)sender
{
	if ([[EingabeFeld stringValue]length])
	  {
		
		NSMutableDictionary* neuesProjektDic=[NSMutableDictionary dictionaryWithObject:[EingabeFeld stringValue] forKey:@"projekt"];
		[neuesProjektDic setObject: [NSNumber numberWithInt:1] forKey:@"OK"];
		[ProjektArray addObject: neuesProjektDic];
		[EingabeFeld setStringValue:@""];
		[InListeTaste setEnabled:NO];
		[[self window]makeFirstResponder:EingabeFeld];
		
	  }
	[ProjektTable reloadData];
	
}

- (void)setProjektListeArray:(NSArray*)derArray
{
	[ProjektArray setArray:[derArray mutableCopy]];
	[ProjektTable reloadData];
}
#pragma mark -
#pragma mark ProjectTable delegate:

- (void)EingabeChangeNotificationAktion:(NSNotification*)note
{
	NSLog(@"ProjektListe NSTextDidChangeNotification");
	if ([note object]==EingabeFeld)
	  {
		NSLog(@"ProjektListe: Eingabefeld");
	  }
	
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
	//NSLog(@"controlTextDidBeginEditing: %@",[[aNotification  userInfo]objectForKey:@"NSFieldEditor"]);
	//[[self window]makeFirstResponder:InListeTaste];
	[InListeTaste setKeyEquivalent:@"\r"];
	[InListeTaste setEnabled:YES];
}
#pragma mark -
#pragma mark ProjectTable Data Source:

- (long)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [ProjektArray count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(long)rowIndex
{
    NSDictionary *einProjektDic;
	if (rowIndex<[ProjektArray count])
	  {
		NS_DURING
			einProjektDic = [ProjektArray objectAtIndex: rowIndex];
			
		NS_HANDLER
			if ([[localException name] isEqual: @"NSRangeException"])
			  {
				return nil;
			  }
			else [localException raise];
		NS_ENDHANDLER
	  }
	return [einProjektDic objectForKey:[aTableColumn identifier]];;
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex
{
    NSMutableDictionary* einProjektDic;
    if (rowIndex<[ProjektArray count])
	  {
		einProjektDic=[ProjektArray objectAtIndex:rowIndex];
		[einProjektDic setObject:anObject forKey:[aTableColumn identifier]];
	  }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row
{
	{
		//NSLog(@"shouldSelectRow im Bereich: row %d",row);
		//[HomeKnopf setState:0];
		//[HomeKnopf setKeyEquivalent:@""];
		//[OKKnopf setEnabled:YES];
		//[OKKnopf setKeyEquivalent:@"\r"];
		
	}
	return YES;
}
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ([ProjektTable numberOfSelectedRows]==0)
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
	if ((row==[ProjektArray count]-1)&&[[tableColumn identifier] isEqualToString:@"projekt"])
	  {
		NSColor * SuchenFarbe=[NSColor orangeColor];
		//[cell setTextColor:SuchenFarbe];
	  }
	else
	  {
		NSColor * TextFarbe=[NSColor blackColor];
		//[cell setTextColor:TextFarbe];
		
	  }
}
@end
