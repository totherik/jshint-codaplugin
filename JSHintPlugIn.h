//
//  JSHintPlugin.h
//  jshint-codaplugin
//
//  Created by Toth,Erik(ertoth) on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CodaPlugInsController.h"

@class CodaPlugInsController;

@interface JSHintPlugIn : NSObject <CodaPlugIn> {

	CodaPlugInsController* controller;
	
}

@end
