/* rClean */

#import <Cocoa/Cocoa.h>
//#include "Quicktime/Quicktime.h"
@interface rClean : NSWindowController <NSComboBoxDataSource>
{
	NSMutableArray *rowData;
    IBOutlet id ClearAnzahlPop;
    IBOutlet id AnzahlTitelPop;
    IBOutlet id TitelView;
    IBOutlet id ClearBehaltenVariante;
    IBOutlet id TitelBehaltenVariante;
    IBOutlet id EntfernenVariante;
    IBOutlet id NamenView;
    IBOutlet id TextString;
    IBOutlet id TitelPop;
    IBOutlet id TitelString;
    IBOutlet id alleTitelKlickCheck;
	IBOutlet id alleNamenKlickCheck;
	IBOutlet id nurTitelZuNamenCheck;

	IBOutlet id clearListeTaste;
	
	IBOutlet id ExportVariante;
	IBOutlet id ExportFormatVariante;
	IBOutlet id ExportFormatPop;
	IBOutlet id ExportAnzahlPop;
	IBOutlet id ExportOptionenTaste;
	IBOutlet id TaskTabSeite;
	
	
	NSMutableArray*			NamenArray;
	NSMutableArray*			TitelArray;
	NSMutableIndexSet*		NamenIndexSet;
	int						ClearAnzahlOption;
	int						ExportAnzahlOption;
	int						ClearBehaltenOption;
	int						ExportOption;
	int						ExportFormatOption;
	int						nurTitelZuNamenOption;
	BOOL					AnzahlOK;
}
- (IBAction)cancelSheet:(id)sender;
- (IBAction)CleanOK:(id)sender;

- (IBAction)reportClearAnzahl:(id)sender;
- (IBAction)reportClearBehaltenOption:(id)sender;
- (IBAction)reportEntfernenOption:(id)sender;
- (IBAction)reportNamen:(id)sender;
- (IBAction)reportTitel:(id)sender;
- (IBAction)sofortWeg:(id)sender;

//- (void)setAuswahlOption:(int)dieOption;
//- (void)setAuswahlOption:(int)dieOption;
- (void)setClean:(NSDictionary*)dieSettings;
- (void)setTaskTab:(int)dasItem;
- (long)numberOfRowsInTableView:(NSTableView *)aTableView;
- (void)setData: (NSDictionary *)someData forRow: (int)rowIndex;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(long)rowIndex;
- (IBAction)NamenCheckAktion:(id)sender;
- (IBAction)NamenHeaderCheckAktion:(id)sender;
- (IBAction)TitelCheckAktion:(id)sender;
- (IBAction)TitelHeaderCheckAktion:(id)sender;
- (IBAction)clearTitelListe:(id)sender;
//- (IBAction)Clear:(id)sender;
- (void)TitelListeLeeren;
- (void)NamenListeLeeren;
- (IBAction)reportNurTitelZuNamenOption:(id)sender;
- (void)deselectNamenListe;
- (void)alleNamenSchwarz;
- (NSDictionary *)dataForRow: (int)rowIndex;
- (void)setNamenArray:(NSArray*)derNamenArray;
- (void)setTitelArray:(NSArray*)derTitelArray;
- (NSArray*)TitelArray;
- (NSArray*)NamenArray;
- (NSArray*)klickNamenArray;
- (NSArray*)klickTitelArray;
-(NSDictionary*)selektierteNamenZeile;
- (void)enableNamenAuswahl:(BOOL)derStatus;
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row;
-(void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn;
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn;

- (IBAction)reportExport:(id)sender;
- (IBAction)reportExportAnzahl:(id)sender;
- (IBAction)reportExportOption:(id)sender;
- (IBAction)reportExportFormatOption:(id)sender;
- (IBAction)reportExportFormat:(id)sender;
- (IBAction)reportExportOptionenTaste:(id)sender;


@end
