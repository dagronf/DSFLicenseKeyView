//
//  AppDelegate.swift
//  DSFLicenseKeyDemoSwift
//
//  Created by Darren Ford on 19/12/18.
//  Copyright © 2018 Darren Ford. All rights reserved.
//

import Cocoa

import DSFLicenseKeyView

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var readonlyLicenseKey: DSFLicenseKeyControlView!

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application

		readonlyLicenseKey.licenseKey = "SF234-ASF32-ZXVCV"
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

