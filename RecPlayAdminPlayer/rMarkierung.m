#import "rMarkierung.h"

@implementation rMarkierung
- (id) init
{
	self=[super initWithWindowNibName:@"RPMarkierung"];
	return self;
}

- (void)awakeFromNib
{
	NSColor * TitelFarbe=[NSColor blueColor];
	NSFont* TitelFont;
	TitelFont=[NSFont fontWithName:@"Helvetica" size: 24];
	[TitelString setFont:TitelFont];
	[TitelString setTextColor:TitelFarbe];
	NSFont* TextFont;
	TextFont=[NSFont fontWithName:@"Helvetica" size: 14];
	[TextString setFont:TextFont];
	[MarkierungVariante setFont:TextFont];
	
}

- (void)setNamenString:(NSString*)derName
{
//	[NamenString setStringValue:derName];
}
- (IBAction)reportMarkierungVariante:(id)sender
{
	[NSApp stopModalWithCode:1];
	int var=[[MarkierungVariante selectedCell]tag];
	NSNumber* VariantenNummer=[NSNumber numberWithInt:var];
	NSMutableDictionary* VariantenDic=[NSMutableDictionary dictionaryWithObject:VariantenNummer forKey:@"MarkierungVariante"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"MarkierungOption" object:self userInfo:VariantenDic];
}
- (IBAction)reportAbbrechen:(id)sender
{
	   [NSApp stopModalWithCode:0];
}
@end
