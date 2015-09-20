/* rAbspielanzeige */

#import <Cocoa/Cocoa.h>

@interface rAbspielanzeige : NSView
{
	float Max;
	float Rahmenhoehe, Rahmenbreite;
	float Feldbreite;
	float Feldhoehe;
	//int AnzFelder;
	float Level;
	//int Grenze;
}
- (void)setLevel:(float) derLevel;
- (void)drawLevelmeter;
- (void)setMax:(float)dasMax;
@end
