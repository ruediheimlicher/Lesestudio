#import "rArchivView.h"

@implementation rArchivView
- (void)keyDown:(NSEvent *)theEvent
{
	int nr=[theEvent keyCode];
	NSString* Taste=[theEvent characters];
	NSLog(@"Archivliste keyDown: %@   %@",[theEvent characters],Taste);	
	//if([[Taste description]isEqualToString:@"\r"])
	//	NSLog(@"                    Enter");
	NSNumber* KeyNummer;
	KeyNummer=[NSNumber numberWithInt:nr];
	//NSLog(@"keyDown: %@",[theEvent characters]);
	//NSLog(@"ArchivListe keyDown nr: %d  char: %@",nr,[theEvent characters]);
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	//[nc postNotificationName:@"Pfeiltaste" object:KeyNummer];
	
	if ([[Taste description]isEqualToString:@"\r"]) 
	  {
		NSString* EnterKeyQuelle;
		EnterKeyQuelle=@"ArchivListe";
		[nc postNotificationName:@"EnterKey" object:EnterKeyQuelle];
		return;
	  }
	[super keyDown:theEvent];
}

@end
