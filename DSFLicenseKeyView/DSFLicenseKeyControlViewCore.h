//
//  DSFLicenseKeyControlViewCore.h
//  DSFLicenseKeyView
//
//  Created by Darren Ford on 19/12/18.
//  Copyright © 2018 Darren Ford. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSFLicenseKeyControlViewCore : NSView

/**
 Configure the license key with segment count and size

 @param count The number of segments in the license key
 @param size The number of characters used in each segment
 */
- (void)configureWithSegmentCount:(NSUInteger)count size:(NSUInteger)size;

/**
 Configure the license key with segment count and size and an initial license key

 @param count The number of segments in the license key
 @param size The number of characters used in each segment
 @param key The key to display
 */
- (void)configureWithSegmentCount:(NSUInteger)count size:(NSUInteger)size key:(NSString*)key;

//! The license key name. Will be used to identify the control in VoiceOver
@property (nonatomic, strong) IBInspectable NSString* name;

//! Number of segments in the key
@property (nonatomic, assign) IBInspectable NSUInteger segmentCount;

//! The size of each segment in the key
@property (nonatomic, assign) IBInspectable NSUInteger segmentSize;

//! The character to use when calculating the widths of the segments. Defaults to 'W'
@property (nonatomic, strong) IBInspectable NSString* widthCharacterCalculator;

//! The character to use when calculating the widths of the segments. Defaults to '•'
@property (nonatomic, strong) IBInspectable NSString* placeholderCharacter;

//! Font being used for the display segments
@property (nonatomic, readonly) NSFont* textFont;

//! The license key to be displayed
@property (nonatomic, strong) NSString* licenseKey;

//! A formatted version of the license key (if the key is invalid, returns nil)
@property (nonatomic, readonly) NSAttributedString* attributedLicenseKey;

//! Is the content of the license key valid?
@property (nonatomic, readonly) BOOL valid;

@property (nonatomic, strong) NSCharacterSet* allowedCharacters;

//! Returns a string of placeholder text that represents a valid license key for the current settings
@property (nonatomic, readonly) NSString* placeholderText;

//! Called when the user changes the license key
- (void)licenseKeyDidChange:(NSString*)newLicenseKey;

//! Returns a formatted string representing the provided license key
- (NSAttributedString*)formattedLicenseKeyStringForKey:(NSString*)licenseKey;

@end

NS_ASSUME_NONNULL_END
