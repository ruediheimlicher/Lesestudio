#import <Cocoa/Cocoa.h>

@interface rAdminDS : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
   NSMutableArray *rowData;
	NSMutableArray* AufnahmeFiles;
	NSMutableArray* AuswahlArray;
	NSMutableArray* MarkArray;
	NSMutableArray* UserMarkArray;
    BOOL _editable;
}

- (id)initWithRowCount: (long)rowCount;


- (long)rowCount;
- (NSArray*)rowData;
- (BOOL)isEditable;
- (void)setEditable:(BOOL)b;


- (void)setData: (NSDictionary *)someData forRow: (long)rowIndex;
- (NSDictionary *)dataForRow: (long)rowIndex;
- (int)ZeileVonLeser:(NSString*)derLeser;

- (void)setAufnahmeFiles:(NSArray*)derArray forRow: (long)dieZeile;
- (NSArray*)AufnahmeFilesFuerZeile:(long)dieZeile;
- (NSArray*)AufnahmeFiles;
- (void)deleteZeileMitAufnahme:(NSString*)aufnahme;

- (void)setMarkArray:(NSArray*)derArray forRow:(long)dieZeile;
- (void)setMark:(BOOL)derStatus forRow:(long)dieZeile forItem:(long)dasItem;
- (NSArray*)MarkArrayForRow:(long)dieZeile;
- (BOOL)MarkForRow:(long)dieZeile forItem:(long)dasItem;

- (void)setAuswahl:(long)dasItem forRow:(long) rowIndex;
- (int)AuswahlFuerZeile:(long)dieZeile;



- (void) insertRowAt:(long)rowIndex;
- (void) insertRowAt:(long)rowIndex withData: (NSDictionary *)someData;
- (void) deleteRowAt:(long)rowIndex;
- (void)deleteDataZuName:(NSString*)derName;
- (void) deleteAllData;


@end
