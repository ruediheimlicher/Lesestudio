#import "rAbspielanzeige.h"

@implementation rAbspielanzeige

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) 
	{
		NSRect BalkenRect=[self frame];
		//BalkenRect.size.height-=2;
		Rahmenbreite=BalkenRect.size.width-1;
		Rahmenhoehe=BalkenRect.size.height-2;
		Feldbreite=10.0;
		Feldhoehe=Rahmenhoehe;
		Level=0;
		Max=Rahmenbreite;
      //NSLog(@"Abspielanzeige  Feldbreite: %2.2f  Feldhoehe: %2.2f" , Feldbreite,Feldhoehe);

	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
   //NSLog(@"drawRect");
   {
      
	[self drawLevelmeter];
   }
}
- (void)setLevel:(float) derLevel
{
	if (derLevel>Max)
		Level=Max;
	else
		Level=derLevel;
 //  NSLog(@"Level ein: %f Level aus: %f",derLevel,Level);
}
- (void)drawLevelmeter
{
//	[self lockFocus];
   NSRect BalkenRect=[self frame];
   NSBezierPath *bp = [NSBezierPath bezierPathWithRect:BalkenRect];
   NSColor *color = [NSColor blueColor];
   [color set];
   [bp stroke];
   [NSBezierPath fillRect:BalkenRect];
   
   //BalkenRect.size.height-=2;
   Rahmenbreite=BalkenRect.size.width-2;
   Rahmenhoehe=BalkenRect.size.height-2;
  
   Feldhoehe=Rahmenhoehe;

	Feldbreite= Rahmenbreite/(Max)*(Level);
	NSRect f;
	NSPoint Nullpunkt=NSMakePoint(1,2);
	f=NSMakeRect(Nullpunkt.x+1,Nullpunkt.y-1,Feldbreite,Feldhoehe-1);
   
   //NSLog(@"draw Max: %2.2f w: %2.2f h: %2.2f level: %2.2f",Max,BalkenRect.size.width,BalkenRect.size.height,Level);
	[[NSColor redColor]set];
	[NSBezierPath strokeRect:BalkenRect];
  // [NSBezierPath fillRect:BalkenRect];
	//[[NSColor greenColor] set];
//	NSColor* BalkenFarbe=[NSColor colorWithDeviceRed:90.0/255 green:255.0/255 blue:130.0/255 alpha:1.0];
   NSColor* BalkenFarbe=[NSColor colorWithDeviceRed:90.0/255 green:90.0/255 blue:255.0/255 alpha:0.5];
	
   [BalkenFarbe set];
	[NSBezierPath fillRect:f];
	f=NSMakeRect(Feldbreite+1,Nullpunkt.y,Rahmenbreite-1,Feldhoehe-1);
	[[NSColor blackColor]set];
	//[NSBezierPath strokeRect:f];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:f];
//	BalkenRect.size.height-=1;
	BalkenRect.size.width-=1;
	[[NSColor lightGrayColor]set];
	[NSBezierPath strokeRect:BalkenRect];
	
//	[self unlockFocus];
	
}
- (void)setMax:(float)dasMax
{
   if (dasMax)
   {
      Max=dasMax;
   }
   
   //NSLog(@"Abspielanzeige max: %f dasMax: %f",Max, dasMax);
}

@end
