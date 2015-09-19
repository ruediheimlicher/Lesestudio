/* rEinzelNamen */

#import <Cocoa/Cocoa.h>
#import "rEingabeFeld.h"
@interface rEinzelNamen : NSWindowController <NSComboBoxDataSource>
{
    IBOutlet		id			CancelTaste;
    IBOutlet		id			DeleteTaste;
    rEingabeFeld*				NamenFeld;
    IBOutlet		id			NamenTable;
    IBOutlet		id			OKTaste;
    IBOutlet		id			SchliessenTaste;
    IBOutlet		id			UbernehmenTaste;
    rEingabeFeld*				VornamenFeld;
	IBOutlet		id          NamenListeView;
	NSMutableArray*				NamenArray;
	NSMutableDictionary*		NamenDic;
	NSString*					aktuellesProjekt;
	NSTextField*				LesestudioString;
	NSTextField*				StartString;
}
- (IBAction)reportCancel:(id)sender;
- (IBAction)reportClose:(id)sender;
- (IBAction)reportDelete:(id)sender;
- (IBAction)reportOK:(id)sender;
- (IBAction)reportUbernehmen:(id)sender;
- (NSString*)stringSauberVon:(NSString*)derString;
- (IBAction)addNamenZeile:(id)sender;
- (NSArray*)NamenArray;

@end
