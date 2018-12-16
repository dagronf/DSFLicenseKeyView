//
//  DSFLicenseKeyControlView.h
//  custom license field
//
//  Created by Darren Ford on 19/01/2016.
//  Copyright © 2016 Darren Ford. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DSFLicenseKeyControlViewCore.h"

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface DSFLicenseKeyControlView : DSFLicenseKeyControlViewCore

//! Create a new read-only license key control
+ (DSFLicenseKeyControlView*)create;

//! Create a new read-only license key control with 'count' segments and 'size' characters per segment
+ (DSFLicenseKeyControlView*)createWithName:(NSString* _Nonnull)name
							   segmentCount:(NSUInteger)count
								segmentSize:(NSUInteger)size;

//! Create a new read-only license key control with 'count' segments and 'size' characters per segment
+ (DSFLicenseKeyControlView*)createWithName:(NSString* _Nonnull)name
							   segmentCount:(NSUInteger)count
								segmentSize:(NSUInteger)size
										key:(NSString* _Nonnull)key;

@end

NS_ASSUME_NONNULL_END
