//
//  DSFLicenseKeyControlViewCore.m
//  DSFLicenseKeyView
//
//  Created by Darren Ford on 17/12/18.
//  Copyright © 2018 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "DSFLicenseKeyControlViewCore.h"

NSString* const DSFLicenseSegmentSeparatorString = @"-";
NSString* const DSFLicenseSegmentCharacterWidthCharString = @"W";  // For chinese, might override to use @"新" instead
NSString* const DSFLicenseSegmentPlaceholderCharString = @"•";

@interface DSFLicenseKeyControlViewCore ()
@property (nonatomic, strong) NSFont* textFont;
@end


@implementation DSFLicenseKeyControlViewCore

- (void)configure
{
	// We'll do all of our own sizing, thanks.
	[self setTranslatesAutoresizingMaskIntoConstraints:NO];

	// Default to alphanumeric
	_allowedCharacters = [NSCharacterSet alphanumericCharacterSet];
	_widthCharacterCalculator = DSFLicenseSegmentCharacterWidthCharString;
	_placeholderCharacter = DSFLicenseSegmentPlaceholderCharString;
	_textFont = [NSFont userFixedPitchFontOfSize:14];
	_name = NSLocalizedString(@"License Key", @"Default identifier for a license key field");
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self)
	{
		[self configure];
	}
	return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self)
	{
		[self configure];
	}
	return self;
}

// MARK: - Configure

- (void)configureWithSegmentCount:(NSUInteger)count size:(NSUInteger)size
{
	[self setSegmentCount:count];
	[self setSegmentSize:size];
	[self setupControl];
}

- (void)configureWithSegmentCount:(NSUInteger)count size:(NSUInteger)size key:(NSString*)key
{
	[self setSegmentCount:count];
	[self setSegmentSize:size];
	[self setLicenseKey:key];
	[self setupControl];
}

- (void)setAllowedCharacters:(NSCharacterSet *)allowedCharacters
{
	[self willChangeValueForKey:@"allowedCharacters"];

	_allowedCharacters = allowedCharacters;

	// Reset the license
	[self setLicenseKey:@""];

	[self didChangeValueForKey:@"allowedCharacters"];
}

// MARK: Values

- (BOOL)valid
{
	return [self isValidLicenseKey:_licenseKey];
}

//! Is the specified key a valid key?
- (BOOL)isValidLicenseKey:(NSString*)key
{
	if ([key length] == 0)
	{
		return NO;
	}
	NSArray* arr = [key componentsSeparatedByString:DSFLicenseSegmentSeparatorString];
	if ([arr count] == _segmentCount)
	{
		for (NSInteger count = 0; count < [arr count]; count++)
		{
			if ([arr[count] length] != [self segmentSize])
			{
				return NO;
			}
		}
		return YES;
	}

	return NO;
}

- (NSArray*)segments
{
	if (![self valid])
	{
		return nil;
	}
	return [_licenseKey componentsSeparatedByString:DSFLicenseSegmentSeparatorString];
}

- (void)setupControl
{
	// Deliberately empty
}

- (NSString*)placeholderText
{
	NSMutableString* str = [[NSMutableString alloc] init];
	for (NSUInteger e = 0; e < [self segmentCount]; e++)
	{
		for (NSUInteger c = 0; c < [self segmentSize]; c++)
		{
			[str appendString:DSFLicenseSegmentCharacterWidthCharString];
		}
		if (e < [self segmentCount]-1)
		{
			[str appendString:DSFLicenseSegmentSeparatorString];
		}
	}

	return str;
}

//! Return a formatted license key, with attributes to aid visual layout (ie. pretty)
- (NSAttributedString*)formattedLicenseKeyStringForKey:(NSString*)licenseKey
{
	NSMutableAttributedString *result = nil;
	if ([self isValidLicenseKey:licenseKey])
	{
		result = [[NSMutableAttributedString alloc] initWithString:licenseKey];
		[result beginEditing];

		for (NSUInteger count = 1; count<[self segmentCount]; count++)
		{
			NSUInteger offset = count * ([self segmentSize] + 1);
			[result addAttribute:NSKernAttributeName
						   value:@(5)
						   range:NSMakeRange(offset-2, 2)];
		}

		[result addAttribute:NSFontAttributeName
					   value:[self textFont]
					   range:NSMakeRange(0, [licenseKey length])];

		[result endEditing];
	}
	return result;
}

- (NSAttributedString*)attributedLicenseKey
{
	return [self formattedLicenseKeyStringForKey:[self licenseKey]];
}

- (void)licenseKeyDidChange:(NSString*)newLicenseKey
{
	if ([self isValidLicenseKey:newLicenseKey])
	{
		[self setAccessibilityValue:newLicenseKey];
	}
}

/**
 *  Change the value of the license key for the control.
 *
 *  @param licenseKey the license key to display
 */
- (void)setLicenseKey:(NSString *)licenseKey
{
	if (licenseKey == nil)
	{
		return;
	}

	[self willChangeValueForKey:@"valid"];
	[self willChangeValueForKey:@"licenseKey"];
	[self willChangeValueForKey:@"attributedLicenseKey"];

	_licenseKey = licenseKey;
	[self setAccessibilityValue:licenseKey];

	[self didChangeValueForKey:@"attributedLicenseKey"];
	[self didChangeValueForKey:@"licenseKey"];
	[self didChangeValueForKey:@"valid"];

	[self licenseKeyDidChange:licenseKey];
}

// MARK: Draw

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
