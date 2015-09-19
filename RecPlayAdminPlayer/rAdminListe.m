#import "rAdminListe.h"

@implementation rAdminListe
- (BOOL)acceptsFirstResponder
{
	//NSLog(@"Accepting firstResponder");
	 return YES;
}
- (BOOL)resignFirstResponder
{
	//NSLog(@"Resign firstResponder");
	 return YES;
}
- (BOOL)becomeFirstResponder
{
	//NSLog(@"AdminListe Becoming firstResponder");
	[self setNeedsDisplay:YES];
	return YES;
}

- (void)insertText:(NSString*)input
{
	//NSLog(@"insertText: %@",[input description]);
	
}

- (void)keyDown:(NSEvent *)theEvent
{
	int nr=[theEvent keyCode];
	NSString* Taste=[theEvent characters];
	NSLog(@"Adminliste keyDown: %@  Taste %@",[theEvent characters],Taste);	
	//if([[Taste description]isEqualToString:@"\r"])
	//	NSLog(@"                    Enter");
	NSNumber* KeyNummer;
	KeyNummer=[NSNumber numberWithInt:nr];
	//NSLog(@"keyDown: %@",[theEvent characters]);
	//NSLog(@"keyDown AdminListe  nr: %d  char: %@",nr,[theEvent characters]);
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	//[nc postNotificationName:@"Pfeiltaste" object:KeyNummer];
	
	if ([[Taste description]isEqualToString:@"\r"]) 
	{
		NSString* EnterKeyQuelle;
		EnterKeyQuelle=@"AdminListe";
		[nc postNotificationName:@"AdminEnterKey" object:EnterKeyQuelle];
		return;
	}
	if (([theEvent keyCode]  ==125)||([theEvent keyCode]  ==126))
	  {
		NSLog(@"NSUpArrowFunctionKey:%d   NSUpArrowFunctionKey: %d   ",[theEvent keyCode],NSUpArrowFunctionKey);
	[super keyDown:theEvent];
	  }
}


@end
