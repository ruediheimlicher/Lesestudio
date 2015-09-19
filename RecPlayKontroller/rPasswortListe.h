/* rPasswortListe */

#import <Cocoa/Cocoa.h>

@interface rPasswortListe : NSWindowController <NSComboBoxDataSource>
{
    IBOutlet id BearbeitenTaste;
    IBOutlet id LesestudioString;
    IBOutlet id PasswortTable;
    IBOutlet id SchliessenTaste;
    IBOutlet id StartString;
    IBOutlet id TitelString;
	
	NSMutableArray* PasswortArray;
	NSMutableDictionary* PasswortDic;

}

- (IBAction)reportBearbeiten:(id)sender;
- (IBAction)reportCancel:(id)sender;
- (IBAction)reportClose:(id)sender;

- (void)setPasswortArray:(NSArray*)derArray;
- (NSArray*)PasswortArray;
@end
