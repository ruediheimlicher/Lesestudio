//
//  rTestfensterController.h
//  Lesestudio_20
//
//  Created by Ruedi Heimlicher on 03.09.2015.
//  Copyright (c) 2015 Ruedi Heimlicher. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface rTestfensterController : NSViewController


@property  (nonatomic, strong) IBOutlet NSButton*					SchliessenTaste;
@property (nonatomic, strong) IBOutlet NSTextField*				StartFeld;
@property (nonatomic, strong) IBOutlet NSTextField*				AnzeigeFeld;


-(IBAction)reportSchliessenTaste:(id)sender;
-(IBAction)reportAAATaste:(id)sender;


- (void)setzeAnzeigeFeld:(NSString *)nzeige;
@end
