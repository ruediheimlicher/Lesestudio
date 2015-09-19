#import "rEingabeFeld.h"

@implementation rEingabeFeld 

- (id) init
{
    if ((self = [super init]))
	return self;
   return NO;
}


/*
- (void)keyDown:(NSEvent*)theEvent
{
	int nr=[theEvent keyCode];
	NSString* Taste=[theEvent characters];
	NSLog(@"Projektliste keyDown: %@   %@",[theEvent characters],Taste);	
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
		NSMutableDictionary* neuesProjektDic=[NSMutableDictionary dictionaryWithObject:[self stringValue] forKey:@"projekt"];
		[neuesProjektDic setObject: [NSNumber numberWithInt:1] forKey:@"OK"];
		
		//NSString* EnterKeyQuelle;
		
		//EnterKeyQuelle=[NSString stringWithString:@"ArchivListe"];
		//[nc postNotificationName:@"EnterKey" object:EnterKeyQuelle];
		return;
	  }
	[super keyDown:theEvent];
	
}
*/
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
NSLog(@"control textShouldBeginEditing");
return YES;
}
 -(BOOL)textShouldBeginEditing:(NSText *)textObject
 {
 //NSLog(@"textShouldBeginEditing");
 [self selectText:nil];
    return YES;
 }
 /*
 - (BOOL)becomeFirstResponder
 {
  NSLog(@"becomeFirstResponder");

 return YES;
 }
 */
@end
