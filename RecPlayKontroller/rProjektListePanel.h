/* rProjektPanel */

#import <Cocoa/Cocoa.h>

@interface rProjektListePanel : NSWindowController
{
    IBOutlet id EingabeFeld;
    IBOutlet id InListeTaste;
    IBOutlet id LesestudioString;
    IBOutlet id ProjektTable;
    IBOutlet id StartString;
    IBOutlet id TitelString;
    IBOutlet id window;
	
	NSMutableArray* ProjektArray;
	NSMutableDictionary* ProjektDic;
	NSString*		ProjektPfad;
	
}
- (IBAction)reportCancel:(id)sender;
- (IBAction)reportClose:(id)sender;
- (IBAction)reportNeuesProjekt:(id)sender;
- (void)setProjektListeArray:(NSArray*)derArray;
- (NSPanel*)window;
@end
