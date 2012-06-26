//
//  JSHintPlugin.m
//  jshint-codaplugin
//
//  Created by Toth,Erik(ertoth) on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "JSHintPlugin.h"
#import "CodaPlugInsController.h"

@interface JSHintPlugIn ()

- (id)initWithController:(CodaPlugInsController*)inController;

- (void)runJSHint:(id) sender;

@end


@implementation JSHintPlugIn

//2.0.1 and higher
- (id)initWithPlugInController:(CodaPlugInsController*)aController plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle {

    return [self initWithController:aController];

}


- (id)initWithController:(CodaPlugInsController*)inController {
	
	if ( (self = [super init]) != nil ) {
		controller = inController;
		[controller registerActionWithTitle:NSLocalizedString(@"JSHint", @"JSHint") target:self selector:@selector(runOnCurrentView:)];
		[controller registerActionWithTitle:NSLocalizedString(@"Preferences", @"") target:self selector:@selector(showDialog)];
	}
    
	return self;
}


- (NSString*)name {
	return @"JSHint";
}


- (void)textViewWillSave:(CodaTextView*)textView {
	[self runJSHint:textView];
}


- (void)runOnCurrentView:(id) sender {
	CodaTextView* textView = [controller focusedTextView:self];
	[self runJSHint:textView];
}


- (void)showDialog {
	
}

- (BOOL)isJsFile:(NSString*)filePath {
	return [[[filePath pathExtension] lowercaseString] isEqualToString:@"js"];
}

- (void)runJSHint:(CodaTextView*)textView {
	if ( !textView || ![self isJsFile:[textView path]]) {
		return;
	}
	
	// Get the path to the shell script
	NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.erik-toth.plugin.JSHint"];
	NSString* script = [myBundle pathForResource:@"js-call" ofType:@"sh"];
	NSString* resourcePath = [script stringByDeletingLastPathComponent];
	NSLog(@"Shell script path: %@", script);
	
	
	// Create a task...
	NSTask *task;
	task = [[NSTask alloc] init];
	
	// ...and point it to our script
	[task setLaunchPath: @"/bin/bash"];
	[task setCurrentDirectoryPath:resourcePath];
	NSArray *arguments;
	arguments = [NSArray arrayWithObjects:@"js-call.sh", @"jshintwrap.js", @"undef", @"LF", nil];
	[task setArguments: arguments];
	
	// Create the pipe that will send the input data to the script
	NSPipe *inPipe;
	inPipe = [NSPipe pipe];
	[task setStandardInput: inPipe];
	
	// Setup the output pipe
	NSPipe *outPipe;
	outPipe = [NSPipe pipe];
	[task setStandardOutput: outPipe];
	
	[task launch];
	
	// Convert the input string to data
	NSData *textData = [[textView string] dataUsingEncoding:NSUTF8StringEncoding];
	[[inPipe fileHandleForWriting] writeData:textData];
	[[inPipe fileHandleForWriting] closeFile];
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSData *readData;
	while ((readData = [[outPipe fileHandleForReading] availableData]) && [readData length]) {
		[data appendData: readData];
	}
	
	NSString *string;
	string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	//		NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
	//		NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	[task waitUntilExit];
	[task release];
	[data release];
	
	if ([string length] != 0) {
		[controller displayHTMLString:string];
	}

}

@end
