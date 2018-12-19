//
//  DSFMutableLicenseKeyView.m
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

#import "DSFMutableLicenseKeyControlView.h"

#import "RSVerticallyCenteredTextFieldCell/RSVerticallyCenteredTextFieldCell.h"

NSString* const DSFLicenseKeyPasteOverrideString = @"DSFLicenseKeyPasteOverrideString";
NSString* const DSFLicenseKeyPasteString = @"DSFLicenseKeyPasteString";

// Defined in the base class
extern NSString* const DSFLicenseSegmentSeparatorString;
extern NSString* const DSFLicenseSegmentCharacterWidthCharString;

@interface NSString (DSFExtensions)
+ (id)stringWithString:(NSString*)str count:(NSUInteger)count;
@end

@implementation NSString (DSFExtensions)

+ (id)stringWithString:(NSString*)str count:(NSUInteger)count
{
	NSMutableString* placeholder = [[NSMutableString alloc] init];
	for (NSUInteger c = 0; c < count; c++)
	{
		[placeholder appendString:str];
	}
	return [NSString stringWithString:placeholder];
}

@end


// MARK: - Segment formatter

@interface DSFLicenseKeySegmentFormatter : NSFormatter
@property (nonatomic, strong) NSCharacterSet* notAllowedChars;
@property (nonatomic, assign) NSInteger segmentLength;
@property (nonatomic, assign) NSInteger segmentCount;
@property (nonatomic, assign) id delegate;
@end

@implementation DSFLicenseKeySegmentFormatter

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		// Only allow alphanumeric characters
		_notAllowedChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	}
	return self;
}

- (NSString*)stringForObjectValue:(id)value
{
	if (![value isKindOfClass:[NSString class]]) {
		return nil;
	}

	return [value uppercaseString];
}

- (BOOL)isPartialStringValid:(NSString*)partialString
			newEditingString:(NSString**)newString
			errorDescription:(NSString**)error
{
	if ([self isValidLicenseKey:partialString])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:DSFLicenseKeyPasteOverrideString
															object:[self delegate]
														  userInfo:@{ DSFLicenseKeyPasteString : partialString }];
		return NO;
	}

	if ([partialString rangeOfCharacterFromSet:_notAllowedChars].location != NSNotFound)
	{
		*error = @"Unsupported character";
		return NO;
	}
	if (partialString.length > [self segmentLength])
	{
		*error = @"Unsupported character";
		return NO;
	}

	*newString = [partialString uppercaseString];
	return NO;
}

- (BOOL)getObjectValue:(id*)obj
			 forString:(NSString*)string
	  errorDescription:(NSString**)error
{
	*obj = string;
	return YES;
}

//! Is the string a valid license key given the current settings
- (BOOL)isValidLicenseKey:(NSString*)str
{
	NSArray* arr = [str componentsSeparatedByString:DSFLicenseSegmentSeparatorString];
	if ([arr count] == _segmentCount)
	{
		for (NSInteger count = 0; count < [arr count]; count++)
		{
			if ([arr[count] length] != [self segmentLength])
			{
				return NO;
			}
			else if ([arr[count] rangeOfCharacterFromSet:_notAllowedChars].location != NSNotFound)
			{
				return NO;
			}
		}
		return YES;
	}
	return NO;
}

@end

// MARK: - License Key

@interface DSFMutableLicenseKeyControlView () <NSTextFieldDelegate, NSAccessibilityGroup>

//! Layout grid
@property (nonatomic, strong) NSStackView* segmentStack;

//! Array containing the individual text fields
@property (nonatomic, strong) NSMutableArray* fields;

@end

@implementation DSFMutableLicenseKeyControlView

+ (DSFMutableLicenseKeyControlView*)create
{
	return [[DSFMutableLicenseKeyControlView alloc] initWithFrame:NSZeroRect];
}

+ (DSFMutableLicenseKeyControlView*)createMutableWithName:(NSString*)name
											 segmentCount:(NSUInteger)count
											  segmentSize:(NSUInteger)size
{
	DSFMutableLicenseKeyControlView* key = [DSFMutableLicenseKeyControlView create];
	[key setName:name];
	[key configureWithSegmentCount:count size:size];
	return key;
}

//! Create a new read-only license key control with 'count' segments and 'size' characters per segment
+ (DSFMutableLicenseKeyControlView*)createMutableWithName:(NSString*)name
											 segmentCount:(NSUInteger)count
											  segmentSize:(NSUInteger)size
													  key:(NSString*)key
{
	DSFMutableLicenseKeyControlView* view = [DSFMutableLicenseKeyControlView createMutableWithName:name
																					  segmentCount:count
																					   segmentSize:size];
	[view setLicenseKey:key];
	return view;
}


- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self)
	{
		[self setup];
	}
	return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self)
	{
		[self setup];
	}
	return self;
}

- (void)setup
{
	_fields = [NSMutableArray arrayWithCapacity:10];

	_showInvalidIndicator = NO;

	// Respond to DSFSegmentFormatter control when it detects paste of a valid license
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(licenseKeyDidPaste:)
												 name:DSFLicenseKeyPasteOverrideString
											   object:self];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_fields = nil;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setupControl];
}

// MARK: - Configure the UI

- (NSTextField*)createSeparator
{
	NSRect frameRect = NSMakeRect(0, 0, 25, 25);
	NSTextField* lastSep = [[NSTextField alloc] initWithFrame:frameRect];
	[lastSep setStringValue:DSFLicenseSegmentSeparatorString];
	[lastSep setBordered:NO];
	[lastSep setFont:[self textFont]];
	[lastSep setDrawsBackground:NO];
	[lastSep setSelectable:NO];
	[lastSep setTranslatesAutoresizingMaskIntoConstraints:NO];
	[lastSep setAccessibilityElement:NO];
	[lastSep setAccessibilityRole:nil];
	[lastSep setContentHuggingPriority:NSLayoutPriorityRequired
						forOrientation:NSLayoutConstraintOrientationHorizontal];
	[lastSep setContentCompressionResistancePriority:NSLayoutPriorityRequired
									  forOrientation:NSLayoutConstraintOrientationHorizontal];

	NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:[self textFont], NSFontAttributeName, nil];
	NSAttributedString* text = [[NSAttributedString alloc] initWithString:DSFLicenseSegmentSeparatorString
															   attributes:attributes];
	NSSize textSize = [text size];
	[lastSep addConstraint:[NSLayoutConstraint constraintWithItem:lastSep
														attribute:NSLayoutAttributeWidth
														relatedBy:NSLayoutRelationEqual
														   toItem:nil
														attribute:NSLayoutAttributeNotAnAttribute
													   multiplier:1.0
														 constant:textSize.width]];

	return lastSep;
}

- (NSTextField*)createSegmentFieldWithOffset:(NSUInteger)offset
{
	NSString* sizer = [NSString stringWithString:[self widthCharacterCalculator]
										   count:[self segmentSize]];
	NSString* placeholder = [NSString stringWithString:[self placeholderCharacter]
												 count:[self segmentSize]];
	NSRect frameRect = NSMakeRect(0, 0, 100, 25);

	NSTextField* myTextField = [[NSTextField alloc] initWithFrame:frameRect];
	RSVerticallyCenteredTextFieldCell* cell = [[RSVerticallyCenteredTextFieldCell alloc] initTextCell:@""];
	[cell setUsesSingleLineMode:YES];
	[myTextField setCell:cell];

	[myTextField setDelegate:self];
	[myTextField setEditable:YES];
	[myTextField setAlignment:NSTextAlignmentCenter];
	[myTextField setPlaceholderString:placeholder];
	[myTextField setFont:[self textFont]];
	[myTextField setBordered:NO];
	[myTextField setDrawsBackground:NO];
	[myTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
	[myTextField setTag:offset];

	[myTextField setAccessibilityParent:self];
	[myTextField setAccessibilityLabel:[NSString stringWithFormat:@"License Segment %ld", offset+1]];

	[myTextField setContentHuggingPriority:NSLayoutPriorityRequired
							forOrientation:NSLayoutConstraintOrientationHorizontal];
	[myTextField setContentCompressionResistancePriority:NSLayoutPriorityRequired
										  forOrientation:NSLayoutConstraintOrientationHorizontal];

	// Calculate the size of the string.
	NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:[self textFont], NSFontAttributeName, nil];
	NSAttributedString* text = [[NSAttributedString alloc] initWithString:sizer
															   attributes:attributes];
	NSSize textSize = [text size];
	textSize.width += 6;

	[myTextField addConstraint:[NSLayoutConstraint constraintWithItem:myTextField
															attribute:NSLayoutAttributeWidth
															relatedBy:NSLayoutRelationEqual
															   toItem:nil
															attribute:NSLayoutAttributeNotAnAttribute
														   multiplier:1.0
															 constant:textSize.width]];

	DSFLicenseKeySegmentFormatter* formatter = [[DSFLicenseKeySegmentFormatter alloc] init];
	[formatter setSegmentLength:[self segmentSize]];
	[formatter setSegmentCount:[self segmentCount]];
	[formatter setDelegate:self];
	[formatter setNotAllowedChars:[[self allowedCharacters] invertedSet]];
	[myTextField setFormatter:formatter];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textDidChange:)
												 name:NSControlTextDidChangeNotification
											   object:myTextField];

	return myTextField;
}

- (CGSize)intrinsicContentSize
{
	return [self frame].size;
}

- (void)setupControl
{
	[_fields removeAllObjects];

	[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

	_segmentStack = [[NSStackView alloc] initWithFrame:[self frame]];
	[_segmentStack setTranslatesAutoresizingMaskIntoConstraints:NO];

	[_segmentStack setContentHuggingPriority:1000
						   forOrientation:NSLayoutConstraintOrientationHorizontal];
	[_segmentStack setContentCompressionResistancePriority:1000
										 forOrientation:NSLayoutConstraintOrientationHorizontal];
	[_segmentStack setSpacing:4];

	[self setContentHuggingPriority:1000
					 forOrientation:NSLayoutConstraintOrientationHorizontal];
	[self setContentCompressionResistancePriority:1000
											forOrientation:NSLayoutConstraintOrientationHorizontal];

	[self addSubview:_segmentStack];

	NSUInteger entryCount = [self segmentCount];

	for (NSUInteger count = 0; count < entryCount; count++)
	{
		if (count != 0)
		{
			// Put in separator
			[_segmentStack addArrangedSubview:[self createSeparator]];
		}

		NSTextField* myTextField = [self createSegmentFieldWithOffset:count];
		[_fields addObject:myTextField];
		[_segmentStack addArrangedSubview:myTextField];
	}

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_segmentStack]-5-|"
																 options:0
																 metrics:nil
																   views:NSDictionaryOfVariableBindings(_segmentStack)]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[_segmentStack]-6-|"
																 options:0
																 metrics:nil
																   views:NSDictionaryOfVariableBindings(_segmentStack)]];

	[[self segmentStack] setNeedsLayout:YES];
	[[self segmentStack] setNeedsUpdateConstraints:YES];

	[self updateAccessibilityForLicense];
}

- (void)updateAccessibilityForLicense
{
	NSString* formatter = NSLocalizedString(@"Editable License Key Field with %1$ld segments of %2$ld characters", @"Editable key field accessibility identifier");
	NSString* roleDesc = [NSString stringWithFormat:formatter, [self segmentCount], [self segmentSize]];

	[self setAccessibilityElement:YES];
	[self setAccessibilityRole:NSAccessibilityGroupRole];
	[self setAccessibilityRoleDescription:roleDesc];
	[self setAccessibilityLabel:[self name]];
}

#pragma mark - License Key Event Handling

- (void)licenseKeyDidChange:(NSString*)newLicenseKey
{
	NSArray* arr = [newLicenseKey componentsSeparatedByString:DSFLicenseSegmentSeparatorString];
	if ([arr count] == [self segmentCount])
	{
		for (NSInteger count = 0; count < [arr count]; count++)
		{
			if ([arr[count] length] == [self segmentSize])
			{
				[_fields[count] setStringValue:arr[count]];
			}
		}
	}

	[self setAccessibilityValue:[self licenseKey]];
	[self setNeedsDisplay:YES];
}

//! Handler for the NVISegmentFormatter protocol, when receiving a valid paste command
- (void)licenseKeyDidPaste:(NSNotification*)notification
{
	NSString* license = [[notification userInfo] objectForKey:DSFLicenseKeyPasteString];
	NSArray* arr = [license componentsSeparatedByString:DSFLicenseSegmentSeparatorString];
	if ([arr count] == [self segmentCount])
	{
		for (NSInteger count = 0; count < [arr count]; count++)
		{
			if ([arr[count] length] == [self segmentSize])
			{
				[_fields[count] setStringValue:arr[count]];
			}
		}
	}

	[self setLicenseKey:license];
	[self setNeedsDisplay:YES];
}

#pragma mark - Key handling

- (void)textDidChange:(NSNotification*)notification
{
	NSTextField* which = [notification object];

	if ([[which stringValue] length] == [self segmentSize])
	{
		NSInteger tag = [which tag];
		if (tag < [self segmentCount]-1)
		{
			[[self window] makeFirstResponder:[[self fields] objectAtIndex:tag+1]];
		}
		else
		{
			NSBeep();
		}
	}

	BOOL valid = YES;
	NSMutableString* license = [[NSMutableString alloc] init];
	for (NSInteger count = 0; count < [[self fields] count]; count++)
	{
		if ([[[[self fields] objectAtIndex:count] stringValue] length] != [self segmentSize])
		{
			valid = NO;
			break;
		}
		if (valid == YES)
		{
			[license appendString:[[[self fields] objectAtIndex:count] stringValue]];
			if (count < [[self fields] count]-1)
			{
				[license appendString:DSFLicenseSegmentSeparatorString];
			}
		}
	}

	[super setLicenseKey:license];
}

//! Override some standard editing controls to make our field more user-friendly
- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
	NSInteger tag = [control tag];
	if (commandSelector == @selector(deleteBackward:))
	{
		if ([[control stringValue] length] == 0)
		{
			if (tag > 0)
			{
				NSTextField* newFocus = [[self fields] objectAtIndex:tag-1];
				[[self window] makeFirstResponder:newFocus];
				[[newFocus currentEditor] moveToEndOfLine:nil];
				return YES;
			}
			else
			{
				NSBeep();
			}
		}
	}
	else if (commandSelector == @selector(moveRight:))
	{
		NSInteger cursorLoc = [textView selectedRange].location;
		if (tag == [[self fields] count] - 1 && cursorLoc == [self segmentSize])
		{
			NSBeep();
			return NO;
		}

		if ([textView selectedRange].location == [self segmentSize])
		{
			NSTextField* newFocus = [[self fields] objectAtIndex:tag+1];
			[[self window] makeFirstResponder:newFocus];
			[[newFocus currentEditor] setSelectedRange:NSMakeRange(0, 0)];
			return YES;
		}
	}
	else if (commandSelector == @selector(moveLeft:))
	{
		NSInteger cursorLoc = [textView selectedRange].location;
		if (tag == 0 && cursorLoc == 0)
		{
			NSBeep();
			return NO;
		}

		if (cursorLoc == 0)
		{
			NSTextField* newFocus = [[self fields] objectAtIndex:tag-1];
			[[self window] makeFirstResponder:newFocus];
			[[newFocus currentEditor] setSelectedRange:NSMakeRange([self segmentSize], 0)];
			return YES;
		}
	}
	return NO;
}

// MARK: - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	NSRect all = NSMakeRect(0, 0, NSWidth([self frame]), NSHeight([self frame]));

	[[NSColor textBackgroundColor] set];
	NSRectFill(all);

	[[NSColor disabledControlTextColor] set];
	NSFrameRectWithWidth ( all, 1 );

	if (_showInvalidIndicator && ![self valid])
	{
		NSBezierPath* path = [NSBezierPath bezierPath];
		[path moveToPoint:NSMakePoint(0, 1)];
		[path lineToPoint:NSMakePoint(NSWidth([self frame]), 1)];
		[[NSColor systemRedColor] set];
		[path setLineWidth:2];
		[path stroke];
	}
}

// MARK: - Interface Builder

- (void)prepareForInterfaceBuilder
{
	[self setupControl];
	[self layout];
}

@end
