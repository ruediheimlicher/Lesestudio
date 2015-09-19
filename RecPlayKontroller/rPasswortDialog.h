/* rPasswortDialog */

#import <Cocoa/Cocoa.h>
#import "rPasswortEingabeFeld.h"

@interface rPasswortDialog : NSWindowController <NSTextFieldDelegate>
{
    IBOutlet id				altesPWFeld;
    IBOutlet id				CancelTaste;
    IBOutlet id				ChangeTaste;
    IBOutlet id				LesestudioString;
    IBOutlet id				NameFeld;
    IBOutlet id            neuesPW1Feld;
    IBOutlet id				neuesPW2Feld;
    IBOutlet id				TitelString;
	IBOutlet id				altesPWString;
	
	NSData*					altesPasswort;
	BOOL					altesPasswortOK;
	BOOL					neuesPasswortOK;
	int						PasswortFehler;
	NSMutableDictionary*			neuerPasswortDic;
}
- (IBAction)reportAltesPW:(id)sender;
- (IBAction)reportCancel:(id)sender;
- (IBAction)reportChange:(id)sender;
- (IBAction)reportNeuesPW:(id)sender;

- (void)setName:(NSString*)derName mitPasswort:(NSData*)dasPasswort;
- (NSDictionary*)neuerPasswortDic;
@end
