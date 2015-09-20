#import <Cocoa/Cocoa.h>

@interface rArchivDS : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
	NSMutableArray* AufnahmeFiles;
	
    BOOL _editable;
}

- (id)initWithRowCount: (int)rowCount;


- (int)rowCount;

- (BOOL)isEditable;
- (void)setEditable:(BOOL)b;

- (void) insertRowAt:(int)rowIndex withData:(NSString *)derPfad;
- (void) insertRowAt:(int)rowIndex;
- (void) deleteAllRows;

- (void)resetArchivDaten;
- (void)setAufnahmePfad:(NSString*)derAufnahmePfad forRow: (int)dieZeile;
- (void)insertAufnahmePfad:(NSString*)derAufnahmePfad forRow: (int)dieZeile;
- (NSString*)AufnahmePfadFuerZeile:(int)dieZeile;






@end
