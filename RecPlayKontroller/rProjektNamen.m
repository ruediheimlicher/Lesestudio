#import "rProjektNamen.h"

@implementation rProjektNamen
- (id) init
{
    //if ((self = [super init]))
	self = [super initWithWindowNibName:@"RPProjektNamen"];
	{
		OrdnerNamenArray=[[NSMutableArray alloc] initWithCapacity: 0];
	}
	ProjektPfad=[NSString string];
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
	OrdnerNamenDic=[[NSMutableDictionary alloc] initWithCapacity:0];
	OrdnerNamenArray=[[NSMutableArray alloc] initWithCapacity:0];
	
	[ProjektOrdnerTable setDataSource:self];
	[ProjektOrdnerTable setDelegate: self];
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
- (int) anzVolumes
{
	return [OrdnerNamenArray count];
}

- (IBAction)reportCancel:(id)sender
{
	KopierOrdnerName=[NSString string];
	NSString* ProjektString=[NSString string];
	NSMutableDictionary* NotificationDic=[NSMutableDictionary dictionaryWithObject:ProjektString forKey:@"ordnername"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"KopierOrdnerWahl" object:self userInfo:NotificationDic];
	[NSApp stopModalWithCode:0];
	[[self window] orderOut:NULL];
	
}

- (IBAction)reportKopieren:(id)sender
{
	int ProjektIndex=[ProjektOrdnerTable selectedRow];
	//NSLog(@"Projektnamen reportKopieren");
	
	if (ProjektIndex>=0)
	  {
	  KopierOrdnerName=[[OrdnerNamenArray objectAtIndex:ProjektIndex]copy];
		NSString* ProjektString=[OrdnerNamenArray objectAtIndex:ProjektIndex];
		//NSLog(@"Projektnamen reportClose: ProjektString: %@",ProjektString);
		NSMutableDictionary* NotificationDic=[NSMutableDictionary dictionaryWithObject:ProjektString forKey:@"ordnername"];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"KopierOrdnerWahl" object:self userInfo:NotificationDic];
	  }//if ProjektIndex
	   //[NSApp abortModal];
	   //NSLog(@"reportClose ende");
	[NSApp stopModalWithCode:1];
	[[self window] orderOut:NULL];
	
}

- (NSString*)KopierOrdnerName
{
return KopierOrdnerName;
}

- (void)setOrdnerNamenArray:(NSArray*)derNamenArray
{
	OrdnerNamenArray=[derNamenArray mutableCopy];
	[ProjektOrdnerTable reloadData];
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
    return [OrdnerNamenArray count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(long)rowIndex
{
    NSString *einOrdnerName;
	if (rowIndex<[OrdnerNamenArray count])
	  {
		NS_DURING
			einOrdnerName = [OrdnerNamenArray objectAtIndex: rowIndex];
			
		NS_HANDLER
			if ([[localException name] isEqual: @"NSRangeException"])
			  {
				return nil;
			  }
			else [localException raise];
		NS_ENDHANDLER
	  }
	return einOrdnerName;
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex
{
    NSString* einOrdnerName;
    if (rowIndex<[OrdnerNamenArray count])
	  {
		einOrdnerName=[OrdnerNamenArray objectAtIndex:rowIndex];
	  }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(long)row
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
	if ([ProjektOrdnerTable numberOfSelectedRows]==0)
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
	if ([[tableColumn identifier] isEqualToString:@"projektordner"])
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
