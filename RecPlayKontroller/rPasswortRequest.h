/* rPasswortRequest */

#import <Cocoa/Cocoa.h>

@interface rPasswortRequest : NSWindowController
{
    IBOutlet id LesestudioString;
    IBOutlet id NameFeld;
    IBOutlet id PasswortFeld;
    IBOutlet id SchliessenTaste;
	
	NSMutableDictionary*			confirmPasswortDic;
	NSData*							confirmPasswort;
	BOOL							confirmPasswortOK;
	int								PasswortFehler;
}
- (IBAction)reportCancel:(id)sender;
- (IBAction)reportClose:(id)sender;
- (IBAction)reportNeuesPasswort:(id)sender;
- (void)setName:(NSString*)derName mitPasswort:(NSData*)dasPasswort;
@end
