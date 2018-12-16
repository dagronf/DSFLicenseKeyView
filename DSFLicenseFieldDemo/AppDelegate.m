//
//  AppDelegate.m
//  DSFLIcenceField
//
//  Created by Darren Ford on 17/12/18.
//  Copyright © 2018 Darren Ford. All rights reserved.
//

#import "AppDelegate.h"

#import <DSFLicenseKeyView/DSFLicenseKeyView.h>

@interface AppDelegate ()

@property (weak) IBOutlet DSFLicenseKeyControlView *fixedLicenseKey;
@property (weak) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSStackView *keyStack;
@property (weak) IBOutlet DSFLicenseKeyControlView *readonlyKeyInGrid;

@property (weak) IBOutlet DSFMutableLicenseKeyControlView *biggerLicenseKeyView;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application

	[_fixedLicenseKey configureWithSegmentCount:3 size:3 key:@"ABC-DEF-GHI"];

	[self setupDummyStackView];

	[_readonlyKeyInGrid setLicenseKey:@"ABCD-EFGH-IJKL-MNOP"];

	[_biggerLicenseKeyView setLicenseKey:@"3GXGX4543J-AXXX43087S-SDAFGLKSFA"];
}

- (void)setupDummyStackView
{
	DSFLicenseKeyControlView* v;
	v = [DSFLicenseKeyControlView createWithName:@"Eight by Three License Key"
									segmentCount:3
									 segmentSize:8
											 key:@"ABCDEFGH-IJKLMNOP-QRSTUVWX"];
	[_keyStack addArrangedSubview:v];

	DSFMutableLicenseKeyControlView* m;

	m = [DSFMutableLicenseKeyControlView createMutableWithName:@"Four by Six License Key"
												  segmentCount:4
												   segmentSize:6
														   key:@"123456-ABCDEF-CATDOG-NOODLE"];
	[_keyStack addArrangedSubview:m];

	v = [DSFLicenseKeyControlView createWithName:@"Five by Five License Key"
									segmentCount:5
									 segmentSize:5
											 key:@"ABCDE-FGHIJ-KLMNO-PQRST-UVWXY"];
	[_keyStack addArrangedSubview:v];

	m = [DSFMutableLicenseKeyControlView create];
	[m setName:@"Wider Chinese Key Support"];
	[m setWidthCharacterCalculator:@"新"];
	[m setPlaceholderCharacter:@"新"];
	[m configureWithSegmentCount:2 size:6];
	[m setLicenseKey:@"工党全国会议-呼吁承认巴勒"];
	[_keyStack addArrangedSubview:m];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
