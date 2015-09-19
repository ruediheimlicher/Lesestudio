/* rProjektNamen */

#import <Cocoa/Cocoa.h>

@interface rProjektNamen : NSWindowController <NSComboBoxDataSource>
{
    IBOutlet id Kopierentaste;
    IBOutlet id LesestudioString;
    IBOutlet id ProjektOrdnerTable;
    IBOutlet id TitelString;
	
	NSMutableArray* OrdnerNamenArray;
	NSMutableDictionary* OrdnerNamenDic;
	NSString*		ProjektPfad;
	NSString*		KopierOrdnerName;
}
- (IBAction)reportCancel:(id)sender;
- (IBAction)reportKopieren:(id)sender;
- (NSString*)KopierOrdnerName;

- (void)setOrdnerNamenArray:(NSArray*)dieNamen;
@end
