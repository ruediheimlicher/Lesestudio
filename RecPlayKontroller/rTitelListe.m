#import "rTitelListe.h"

@implementation rTitelListe
- (id) init
{
    //if ((self = [super init]))
	self = [super initWithWindowNibName:@"RPTitelListe"];
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
	TitelArray=[[NSMutableArray alloc] initWithCapacity:0];
	
	[TitelTable setDataSource:self];
	[TitelTable setDelegate: self];
	NSFont* RecPlayfont;
	RecPlayfont=[NSFont fontWithName:@"Helvetica" size: 32];
	NSColor * RecPlayFarbe=[NSColor grayColor];
	[LesestudioString setFont: RecPlayfont];
	[LesestudioString setTextColor: RecPlayFarbe];
	NSFont* Titelfont;
	Titelfont=[NSFont fontWithName:@"Helvetica" size: 14];
	NSColor * TitelFarbe=[NSColor grayColor];
	[TitelString setFont: Titelfont];
	[TitelString setTextColor: TitelFarbe];
	[[TitelTable tableColumnWithIdentifier:@"titel"]setEditable:YES];
	[EingabeFeld setDelegate:self];

}

- (void)setTitelArray:(NSArray*)derArray inProjekt:(NSString*)dasProjekt
{
	[ProjektFeld setStringValue:dasProjekt];
	[EingabeFeld setStringValue:@""];
	//NSLog(@"\n\n\n									setTitelArray derArray: %@ dasProjekt: %@",[derArray description],[dasProjekt description]);
	NSArray* tempArray=[derArray copy];//WICHTIG
	
	[TitelArray removeAllObjects];
	NSEnumerator* TitelEnum=[tempArray objectEnumerator];
	id einObjekt;
	while(einObjekt=[TitelEnum nextObject])
	{
		NSMutableDictionary* tempDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		//NSLog(@"einObjekt: %@",[einObjekt description]);
		if ([einObjekt objectForKey:@"titel"])
		{
			[tempDic setObject:[[einObjekt objectForKey:@"titel"]copy]forKey:@"titel"];//copy scheint wichtig zu sein
			//NSLog(@"tempDic 1: %@",[tempDic description]);
			if ([einObjekt objectForKey:@"ok"])
			{
				[tempDic setObject:[einObjekt objectForKey:@"ok"] forKey:@"ok"];
			}
			else
			{
				[tempDic setObject:[NSNumber numberWithBool:YES] forKey:@"ok"];
			}
			//NSLog(@"tempDic 2: %@",[tempDic description]);
		[TitelArray addObject:tempDic];
		}//if titel
		
	}//while
	//NSLog(@"setTitelArray TitelArray Schluss: %@",[TitelArray description]);
	//NSLog(@"setTitelArray tempArray Schluss: %@",[tempArray description]);
	//NSLog(@"setTitelArray derArray Schluss: %@",[derArray description]);
	[TitelTable reloadData];
	if ([TitelArray count])
	{
	[EntfernenTaste setEnabled:YES];
	}
}

- (void)neueZeile:(id) sender
{

NSMutableDictionary* tempTitelDic=[[NSMutableDictionary alloc]initWithCapacity:0];
[tempTitelDic setObject:@"Projekt" forKey:@"projekt"];
[tempTitelDic setObject:[NSNumber numberWithBool:YES] forKey:@"ok"];
[tempTitelDic setObject:[NSString string] forKey:@"titel"];
//NSLog(@"neueZeile: tempTitelDic: %@",[tempTitelDic description]);
[TitelArray addObject:tempTitelDic];
[TitelTable reloadData];
[[self window]makeFirstResponder:TitelTable];
//[[[TitelTable tableColumnWithIdentifier:@"titel"]dataCellForRow:[TitelTable selectedRow]]selectText:nil];
}

- (IBAction)reportNeuerTitel:(id)sender
{
	if ([[EingabeFeld stringValue]length])
	{
		NSMutableDictionary* tempTitelDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		//[tempTitelDic setObject:@"Projekt" forKey:@"projekt"];
		[tempTitelDic setObject:[NSNumber numberWithBool:YES] forKey:@"ok"];
		[tempTitelDic setObject:[EingabeFeld stringValue] forKey:@"titel"];
		[TitelArray addObject:tempTitelDic];
		[TitelTable reloadData];
		[EingabeFeld setStringValue:@""];
		[EinsetzenTaste setEnabled:NO];
		[EntfernenTaste setEnabled:YES];
		[SchliessenTaste setEnabled:YES];
		[[self window]makeFirstResponder:EingabeFeld];
		
	}
}

- (IBAction)reportEntfernen:(id)sender
{
	int tempZeile=[TitelTable selectedRow];
	if (tempZeile>=0)
	{
		[TitelArray removeObjectAtIndex:tempZeile];
		[EntfernenTaste setEnabled:[TitelArray count]];
		[TitelTable reloadData];
	}
}


- (IBAction)reportCancel:(id)sender
{
[TitelTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0]byExtendingSelection:NO];
[[TitelTable tableColumnWithIdentifier:@"titel"]setEditable:NO];
[NSApp stopModalWithCode:0];
[[self window]orderOut:NULL];

}


- (IBAction)reportClose:(id)sender
{
[TitelTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0]byExtendingSelection:NO];
[[TitelTable tableColumnWithIdentifier:@"titel"]setEditable:NO];
NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
[NotificationDic setObject:TitelArray  forKey:@"titelarray"];

//[NotificationDic setObject:[ProjektFeld stringValue] forKey:@"projekt"];

NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
[nc postNotificationName:@"titelliste" object:self userInfo:NotificationDic];

[NSApp stopModalWithCode:1];
[[self window]orderOut:NULL];

}
#pragma mark -
#pragma mark EingabeFeld delegate:

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
//NSLog(@"controlTextDidBeginEditing");
	//NSLog(@"controlTextDidBeginEditing: %@",[[aNotification  userInfo]objectForKey:@"NSFieldEditor"]);
	//[InListeTaste setKeyEquivalent:@"\r"];
  [EinsetzenTaste setEnabled:YES];
	[SchliessenTaste setEnabled:NO];
}

#pragma mark -
#pragma mark ProjectTable Data Source:

- (long)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [TitelArray count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(long)rowIndex
{
//NSLog(@"objectValueForTableColumn: %@",[PasswortArray description]);
   NSDictionary* einTitelDic;

	if (rowIndex<[TitelArray count])
	  {
		NS_DURING
			einTitelDic = [TitelArray objectAtIndex: rowIndex];
			//NSLog(@"einPasswortDic: %@",[einPasswortDic description]);

		NS_HANDLER
			if ([[localException name] isEqual: @"NSRangeException"])
			  {
				return nil;
			  }
			else [localException raise];
		NS_ENDHANDLER
	  }
return [einTitelDic objectForKey:[aTableColumn identifier]];
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex
{
    NSMutableDictionary* einTitelDic;
    if (rowIndex<[TitelArray count])
	  {
		einTitelDic=[TitelArray objectAtIndex:rowIndex];
		[einTitelDic setObject:anObject forKey:[aTableColumn identifier]];

	  }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row
{
  //NSLog(@"shouldSelectRow");
		//if(tableView ==[window firstResponder])
  if ([tableView numberOfSelectedRows])
			{
			[EinsetzenTaste setEnabled:NO];
			[EntfernenTaste setEnabled:YES];
			[SchliessenTaste setEnabled:YES];

			}
		  
  
  
  return YES;
}


@end
