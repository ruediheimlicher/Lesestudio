/* rProjektStart */

#import <Cocoa/Cocoa.h>

@interface rProjektStart : NSWindowController <NSComboBoxDataSource>
{
    IBOutlet id EingabeFeld;
    IBOutlet id InListeTaste;
    IBOutlet id LesestudioString;
    IBOutlet id ProjektTable;
    IBOutlet id AufnehmenTaste;
    IBOutlet id AdminTaste;
	IBOutlet id CancelTaste;
	IBOutlet id NeuesProjektTaste;
    IBOutlet id StartString;
    IBOutlet id TitelString;
	IBOutlet id window;
	NSMutableArray* ProjektArray;
	NSMutableDictionary* ProjektDic;
	NSString*		ProjektPfad;
	
}
- (IBAction)neueZeile:(id)sender;
- (IBAction)reportClose:(id)sender;
- (IBAction)reportCancel:(id)sender;
- (IBAction)reportNeuesProjekt:(id)sender;

- (void)setProjektArray:(NSArray*)derArray;
- (void)setRecorderTaste:(int)derStatus;
- (void)selectProjekt:(NSString*)dasProjekt;
@end
