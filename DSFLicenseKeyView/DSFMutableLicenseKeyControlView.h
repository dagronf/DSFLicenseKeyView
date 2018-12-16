//
//  DSFMutableLicenseKeyControlView.h
//  custom license field
//
//  Created by Darren Ford on 29/01/2016.
//  Copyright © 2016 Darren Ford. All rights reserved.
//

#import "DSFLicenseKeyControlViewCore.h"

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface DSFMutableLicenseKeyControlView : DSFLicenseKeyControlViewCore

@property (nonatomic, assign) IBInspectable BOOL showInvalidIndicator;

//! Create a new mutable license key control
+ (DSFMutableLicenseKeyControlView*)create;

+ (DSFMutableLicenseKeyControlView*)createMutableWithName:(NSString* _Nonnull)name
											 segmentCount:(NSUInteger)count
											  segmentSize:(NSUInteger)size;

+ (DSFMutableLicenseKeyControlView*)createMutableWithName:(NSString* _Nonnull)name
											 segmentCount:(NSUInteger)count
											  segmentSize:(NSUInteger)size
													  key:(NSString* _Nonnull)key;

@end

NS_ASSUME_NONNULL_END
