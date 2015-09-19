/* rProjektListe */

#import <Cocoa/Cocoa.h>
#import "rEingabeFeld.h"
@interface rProjektListe : NSWindowController <NSComboBoxDataSource, NSTextViewDelegate, NSTextFieldDelegate>
{
  rEingabeFeld* EingabeFeld;
	IBOutlet id FixTaste;
	IBOutlet id PWTaste;
	IBOutlet id InListeTaste;
	IBOutlet id AuswahlenTaste;
    IBOutlet id EntfernenTaste;
	IBOutlet id SchliessenTaste;
	IBOutlet id CancelTaste;
    IBOutlet id ProjektTable;
    IBOutlet id window;
	IBOutlet id TitelString;
	IBOutlet id LesestudioString;
	IBOutlet id StartString;
	
	NSMutableArray*			ProjektArray;
	NSMutableArray*			neueProjekteArray;
	NSMutableDictionary*	neuesProjektDic;
	NSString*				aktuellesProjekt;
	BOOL					vomStart;	
}
- (IBAction)okAktion:(id)sender;
- (IBAction)reportCancel:(id)sender;
- (IBAction)reportClose:(id)sender;
- (IBAction)reportAuswahlen:(id)sender;
- (IBAction)reportEntfernen:(id)sender;
- (IBAction)reportNeuesProjekt:(id)sender;
- (void)setProjektListeArray:(NSArray*)derArray inProjekt:(NSString*)dasProjekt;
- (void)setNeuesProjekt;
- (void)setProjektListeLeer;
- (void)setMitUserPasswort:(int)derStatus;
- (void)setTitelFix:(int)derStatus;
- (void)setVomStart:(BOOL)derStatus;

- (void)resetPanel;
@end
