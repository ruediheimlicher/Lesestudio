#import "rArchivDS.h"

@implementation rArchivDS

-(id) init
{
    return [self initWithRowCount: 0];
}

- (id)initWithRowCount: (int)rowCount
{
    int i;

    if ((self = [super init]))
    {
        _editable = YES;
    
		
		AufnahmeFiles=[[NSMutableArray alloc] initWithCapacity: rowCount];
		for (i=0; i < rowCount; i++)
        {
            [AufnahmeFiles addObject: [NSString  string]];
		}


    }
    return self;
}

- (void)dealloc
{
 
}

- (BOOL)isEditable
{
    return _editable;
}

- (void)setEditable:(BOOL)b
{
    _editable = b;
}

#pragma mark -
#pragma mark Accessing Row Data:

- (void)resetArchivDaten
{
	[AufnahmeFiles removeAllObjects];
}

- (void)setAufnahmePfad:(NSString*)derAufnahmePfad forRow: (int)dieZeile
{
	NSString* tempString=[derAufnahmePfad copy];
	//tempArray=[derArray copy];
	//[derAufnahmePfad release];
	//NSString* eineZeile;
	[AufnahmeFiles addObject:tempString];

	//eineZeile =[derAufnahmePfad copy];
}

- (void)insertAufnahmePfad:(NSString*)derAufnahmePfad forRow: (int)dieZeile
{
   NSString* tempString=[derAufnahmePfad copy];
   //tempArray=[derArray copy];
   //[derAufnahmePfad release];
   //NSString* eineZeile;
   [AufnahmeFiles insertObject:tempString atIndex:dieZeile];
   
   //eineZeile =[derAufnahmePfad copy];
}


- (NSString*)AufnahmePfadFuerZeile:(int)dieZeile
{
	//
	NSString* eineZeile;
	eineZeile=[AufnahmeFiles objectAtIndex:dieZeile];
	//NSLog(@"AufnahmeFilesFuerZeile: %d   Aufnahme: %@ ",dieZeile,eineZeile);
	return eineZeile;
}

#pragma mark -

- (int)rowCount
{
    return [AufnahmeFiles count];
}

#pragma mark -

- (void) insertRowAt:(int)rowIndex
{
    [self insertRowAt: rowIndex withData: [NSString string]];
}

- (void) insertRowAt:(int)rowIndex withData:(NSString *)derPfad
{
    [AufnahmeFiles insertObject: derPfad atIndex: rowIndex];
}

- (void) deleteRowAt:(int)rowIndex
{    
    [AufnahmeFiles removeObjectAtIndex: rowIndex];
}

- (void) deleteAllRows
{    
    [AufnahmeFiles removeAllObjects];
}



- (void)setAuswahl:(int)dasItem forRow:(int) rowIndex
{
	NSNumber* tempItem=[NSNumber numberWithInt:dasItem];
}

#pragma mark -
#pragma mark Table Data Source:

- (long)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [AufnahmeFiles count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn 
    row:(long)rowIndex
{
    NSString *eineZeile;
        
   
	eineZeile = [AufnahmeFiles objectAtIndex: rowIndex];
    
    return eineZeile ;
}

- (void)tableView:(NSTableView *)aTableView 
    setObjectValue:(id)anObject 
    forTableColumn:(NSTableColumn *)aTableColumn 
    row:(long)rowIndex
{
    NSString *eineZeile;
    
    
    {
		eineZeile = [AufnahmeFiles objectAtIndex: rowIndex];
        
        [AufnahmeFiles insertObject:anObject atIndex:rowIndex];
    }
}

#pragma mark -
#pragma mark Table Delegate:

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(long)rowIndex
{
   NSLog(@"Archiv Delegate tableView  shouldEditTableColumn: %ld",rowIndex);

    return YES;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(long)row
{
	if ([[tableColumn identifier] isEqualToString:@"aufnahmen"])
	{
			
	}
		
	
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(long)row;
{
	//NSLog(@"Archiv Delegate tableView  shouldSelectRow: %d",row);
	NSNumber* ZeilenNummer;
	ZeilenNummer=[NSNumber numberWithLong:row];
   NSNumber* lastZeilenNumber = [NSNumber numberWithDouble:[tableView selectedRow]];
	NSMutableDictionary* ArchivZeilenDic=[NSMutableDictionary dictionaryWithObject:ZeilenNummer forKey:@"ArchivZeilenNummer"];
   [ArchivZeilenDic setObject:lastZeilenNumber forKey:@"lastarchivzeilennummer"];
	[ArchivZeilenDic setObject:@"ArchivView" forKey:@"Quelle"];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"selektierteZeile" object:ArchivZeilenDic]; // >> ZeilenNotifikationAktion

	return YES;
}
@end
