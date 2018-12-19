//
//  DSFLicenseKeyView.m
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

#import "DSFLicenseKeyControlView.h"

#import "RSVerticallyCenteredTextFieldCell/RSVerticallyCenteredTextFieldCell.h"

extern NSString* const DSFLicenseSegmentSeparatorString;
extern NSString* const DSFLicenseSegmentCharacterWidthCharString;
extern NSString* const DSFLicenseSegmentPlaceholderCharString;

@interface DSFLicenseKeyControlViewCellClass : RSVerticallyCenteredTextFieldCell {}
@end

@implementation DSFLicenseKeyControlViewCellClass
- (BOOL)acceptsFirstResponder
{
	return YES;
}
@end

#pragma mark License Key View

@interface DSFLicenseKeyControlView ()
@property (nonatomic, strong) NSTextField* readonly;
@end

@implementation DSFLicenseKeyControlView

+ (DSFLicenseKeyControlView*)create
{
	return [[DSFLicenseKeyControlView alloc] initWithFrame:NSZeroRect];
}

+ (DSFLicenseKeyControlView*)createWithName:(NSString*)name
							   segmentCount:(NSUInteger)count
								segmentSize:(NSUInteger)size
{
	DSFLicenseKeyControlView* key = [DSFLicenseKeyControlView create];
	[key setName:name];
	[key configureWithSegmentCount:count size:size];
	return key;
}

//! Create a new read-only license key control with 'count' segments and 'size' characters per segment
+ (DSFLicenseKeyControlView*)createWithName:(NSString*)name
							   segmentCount:(NSUInteger)count
								segmentSize:(NSUInteger)size
										key:(NSString*)key
{
	DSFLicenseKeyControlView* view = [DSFLicenseKeyControlView createWithName:name
																 segmentCount:count
																  segmentSize:size];
	[view setLicenseKey:key];
	return view;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setupControl];
}

#pragma mark - Setup and configuration

- (CGSize)intrinsicContentSize
{
	return [self frame].size;
}

//! Configure the control to be a read-only license field
- (void)setupControl
{
	NSRect frameRect = [super frame];

	[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

	[self setAccessibilityElement:YES];
	[self setAccessibilityRole:NSAccessibilityTextFieldRole];
	[self setAccessibilityRoleDescription:NSLocalizedString(@"Read-Only License Key Field", @"Read-only key field accessibility identifier")];
	[self setAccessibilityLabel:[self name]];
	[self setAccessibilityValue:[self licenseKey]];

	_readonly = [[NSTextField alloc] initWithFrame:frameRect];

	DSFLicenseKeyControlViewCellClass *selectableTextCell = [[DSFLicenseKeyControlViewCellClass alloc] initTextCell:@""];
	[_readonly setCell:selectableTextCell];

	[_readonly setEditable:NO];
	[_readonly setSelectable:YES];
	[_readonly setFont:[self textFont]];
	[_readonly setBordered:NO];
	[_readonly setDrawsBackground:NO];
	[_readonly setTranslatesAutoresizingMaskIntoConstraints:NO];
	[_readonly setAllowsEditingTextAttributes:YES];
	[[_readonly cell] setUsesSingleLineMode:YES];
	[[_readonly cell] setWraps:NO];

	[self addSubview:_readonly];

	[self setContentHuggingPriority:NSLayoutPriorityRequired
					 forOrientation:NSLayoutConstraintOrientationHorizontal];
	[self setContentCompressionResistancePriority:NSLayoutPriorityRequired
								   forOrientation:NSLayoutConstraintOrientationHorizontal];

	// Generate minimum size placeholder
	NSAttributedString* placeholder = [self formattedLicenseKeyStringForKey:[self placeholderText]];
	NSSize textSize = [placeholder size];

	NSSize newFrameSize = textSize;
	newFrameSize.height += 6;
	newFrameSize.width += 6;
	[self setFrameSize:newFrameSize];

	NSDictionary* metrics = @{@"ts": @(textSize.width+1)};

	[self addConstraint:[NSLayoutConstraint constraintWithItem:_readonly
													 attribute:NSLayoutAttributeCenterY
													 relatedBy:NSLayoutRelationEqual
														toItem:[_readonly superview]
													 attribute:NSLayoutAttributeCenterY
													multiplier:1.f constant:0.f]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_readonly(ts)]-3-|"
																 options:0
																 metrics:metrics
																   views:NSDictionaryOfVariableBindings(_readonly)]];

	[_readonly setContentHuggingPriority:NSLayoutPriorityRequired
						  forOrientation:NSLayoutConstraintOrientationHorizontal];
	[_readonly setContentCompressionResistancePriority:NSLayoutPriorityRequired
										forOrientation:NSLayoutConstraintOrientationHorizontal];

	[self licenseKeyDidChange:[self licenseKey]];

	[self setContentHuggingPriority:1000
					 forOrientation:NSLayoutConstraintOrientationHorizontal];
	[self setContentCompressionResistancePriority:1000
								   forOrientation:NSLayoutConstraintOrientationHorizontal];

	[self setNeedsUpdateConstraints:YES];
	[self updateConstraints];
}

#pragma mark - Utility functions

- (void)licenseKeyDidChange:(NSString*)newLicenseKey
{
	newLicenseKey = newLicenseKey ?: @"";
	[[self readonly] setStringValue:newLicenseKey];

	NSAttributedString* formattedKey = [self formattedLicenseKeyStringForKey:newLicenseKey];
	[[self readonly] setAttributedStringValue:formattedKey];
}

#pragma mark - Drawing functions

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];

	NSRect all = NSMakeRect(0, 0, NSWidth([self frame]), NSHeight([self frame]));

	[[NSColor disabledControlTextColor] set];
	NSFrameRectWithWidth ( all, 1 );
}

#pragma mark - Interface Builder

- (void)prepareForInterfaceBuilder
{
	/// Put in a dummy license key
	NSMutableString* str = [[NSMutableString alloc] init];
	for (NSInteger i = 0; i < [self segmentCount]; i++)
	{
		for (NSInteger j = 0; j < [self segmentSize]; j++)
		{
			[str appendString:[self placeholderCharacter]];
		}

		if (i != [self segmentCount] - 1)
		{
			[str appendString:DSFLicenseSegmentSeparatorString];
		}
	}
	[self setLicenseKey:str];

	[self setupControl];
}

@end
