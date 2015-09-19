/* rTitelListe */

#import <Cocoa/Cocoa.h>

@interface rTitelListe : NSWindowController <NSTableViewDataSource, NSTextFieldDelegate, NSTableViewDelegate>
{
    IBOutlet id LesestudioString;
    IBOutlet id ProjektFeld;
    IBOutlet id SchliessenTaste;
	IBOutlet id EinsetzenTaste;
	IBOutlet id EntfernenTaste;
    NSMutableArray* TitelArray;
    IBOutlet id TitelString;
    NSTableView* TitelTable;
	NSString* ProjektString;
	NSTextField* EingabeFeld;
}
- (IBAction)reportCancel:(id)sender;
- (IBAction)reportClose:(id)sender;
- (IBAction)reportEntfernen:(id)sender;
- (IBAction)reportNeuerTitel:(id)sender;

- (void)setTitelArray:(NSArray*)derArray inProjekt:(NSString*)dasProjekt;
@end
