//
//  DSFMutableLicenseKeyControlView.h
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
