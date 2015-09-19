//
//  Testfenster.m
//  Lesestudio_20
//
//  Created by Ruedi Heimlicher on 03.09.2015.
//  Copyright (c) 2015 Ruedi Heimlicher. All rights reserved.
//

#import "rTestfensterController.h"


@implementation rTestfensterController

@synthesize AnzeigeFeld;
@synthesize SchliessenTaste;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.StartFeld setStringValue:@"soso"];
   NSLog(@"Testfenster viewDidLoad");
}


-(IBAction)reportSchliessenTaste:(id)sender
{
   
   NSLog(@"Testfenster reportSchliessenTaste Text: %@",[AnzeigeFeld stringValue]);

   [self dismissController:NULL];
}

-(IBAction)reportAAATaste:(id)sender
{
   
}

- (void)setzeAnzeigeFeld:(NSString *)anzeige
{
   NSLog(@"Testfenster setzeAnzeigeFeld anzeige: %@ startfeld: %@",anzeige, [self.StartFeld stringValue]);
   AnzeigeFeld.stringValue = anzeige;
  //[self.AnzeigeFeld setStringValue:@"soso"];
}


@end
