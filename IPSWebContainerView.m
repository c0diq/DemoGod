/* 
Copyright (c) 2007, Marketcircle Inc.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/


#import "IPSWebContainerView.h"

#import "IPSWebAddressBarView.h"
#import "IPSWebToolbarView.h"
#import "IPSStatusBarView.h"
#import "IPSWebAddressField.h"
#import "IPSCategories.h"
#import "IPSScroller.h"

@interface IPSWebContainerView (Private)
- (float)scaleFactor;
- (void)setScaleFactor:(float)aFactor;

- (void)scaleToFit;
- (void)scaleToNatural;
@end

@implementation IPSWebContainerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		isLoading = NO;
		count = 1;
		scaleFactor = 1.0;
		shouldScaleToFit = NO;
    }
    return self;
}

- (void)awakeFromNib;
{
	[webView setMaintainsBackForwardList:YES];

	// -----------------------------------------------------------------------------
	// Default Page
	//[self loadPageWithAddress:@"http://sylvain.local:8099/content/home.html"];
	[self toggleHideLocationBar:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressEstimateChanged:) name:WebViewProgressEstimateChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressFinished:) name:WebViewProgressFinishedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressStarted:) name:WebViewProgressStartedNotification object:nil];
	
	[[self window] performSelector:@selector(makeFirstResponder:) withObject:[self window] afterDelay:0];
}

- (void)replaceScrollersInView:(NSScrollView *)scrollView {		
	// FIXME: this plain don't work.... :P
}


#pragma mark -
#pragma mark Accessors
- (BOOL)isLoading {
    return isLoading;
}

- (void)setIsLoading:(BOOL)inIsLoading {
    isLoading = inIsLoading;
}

- (BOOL)shouldScaleToFit {
	return shouldScaleToFit;
}
- (void)setShouldScaleToFit:(BOOL)aBool {
	if (shouldScaleToFit != aBool) {
		shouldScaleToFit = aBool;

		[self doScale];
	}
}

#pragma mark -
#pragma mark Scaling Machinery
- (float)scaleFactor {
	return scaleFactor;
}

- (void)setScaleFactor:(float)aFactor {
	if (scaleFactor != aFactor) {
		NSClipView *clipView;
		
		if ((clipView = [webView firstDescendentClipView])) {
			[[clipView window] disableFlushWindow];
			[[clipView window] setAutodisplay:NO];
			
			// scale back to natural size...
			NSSize newUnitSize;
			newUnitSize = NSMakeSize(1.0 / scaleFactor, 1.0 / scaleFactor);
			[clipView scaleUnitSquareToSize:newUnitSize];
			
			scaleFactor = aFactor;
			
			// now scale to the target size...
			newUnitSize = NSMakeSize(scaleFactor, scaleFactor);
			[clipView scaleUnitSquareToSize:newUnitSize];
			
			[[clipView window] setAutodisplay:YES];
			[[clipView window] displayIfNeeded];
			
			[[clipView window] enableFlushWindow];
			[[clipView window] flushWindowIfNeeded];
		}
	}
}

- (void)doScale {
	if ([self shouldScaleToFit])
		[self scaleToFit];
	else 
		[self scaleToNatural];
}

- (void)scaleToFit {	
	NSClipView *clipView = [webView firstDescendentClipView];	
	if (clipView == nil) return;

	[self replaceScrollersInView:[clipView enclosingScrollView]];

	NSView *documentView = [clipView documentView];
	if (documentView == nil) return;
	
	float wClip = NSWidth([clipView frame]);
	float wDoc  = NSWidth([documentView frame]);
		
	if (wClip == 0 || wDoc == 0) return;
	
	float newScaleFactor = wClip / wDoc;
	[self setScaleFactor:newScaleFactor];
}

- (void)scaleToNatural {
	if (scaleFactor != 1.0) {
		[self setScaleFactor: 1.0];
	}
}

#pragma mark -
#pragma mark Action Methods

- (IBAction)stop:(id)sender; {
	[webView stopLoading:sender];
}

- (IBAction)reload:(id)sender;
{
	if (isLoading) {
		[webView stopLoading:sender];
	}
	else {
		[webView reload:sender];
	}
}

- (IBAction)toggleScaleToFit:(id)sender {
	[self setShouldScaleToFit:![self shouldScaleToFit]];
}

- (IBAction)openLocation:(id)sender {
	if (isLocationBarHidden) {
		[self toggleHideLocationBar:sender];
	}
	
	[[self window] makeFirstResponder:[addressBar addressField]];
}

- (IBAction)toggleHideLocationBar:(id)sender;
{
	if (isLocationBarHidden)
	{
		isLocationBarHidden = NO;
		
		NSRect wf = [webView frame];
		
		[webView setFrame:NSMakeRect(wf.origin.x,wf.origin.y,wf.size.width,wf.size.height - [addressBar frame].size.height)];
		[addressBar setHidden:NO];
		[self setNeedsDisplay:YES];
		
	}
	else
	{
		isLocationBarHidden = YES;
		
		NSRect wf = [webView frame];
		
		[webView setFrame:NSMakeRect(wf.origin.x,wf.origin.y,wf.size.width,wf.size.height + [addressBar frame].size.height)];
		[addressBar setHidden:YES];
		[self setNeedsDisplay:YES];
	}
}

- (IBAction)addressFieldDidAct:(id)sender;
{
	NSEvent *event = [NSApp currentEvent];

	WebFrame *mainFrame = [webView mainFrame];	
	WebDataSource *src = [mainFrame provisionalDataSource];
	if (!src)
		src = [mainFrame dataSource];
	
	NSString *currentUrlStr = [[[src request] URL] absoluteString];
	if ([currentUrlStr isEqualToString:[sender stringValue]])
	{
		// ignore the request, since it can't be enter/return if it's not a key event
		if ([event type] != NSKeyDown)
			return;
		
		BOOL shouldReload = NO;

		NSString *eventCharacters;
		unsigned int characterIndex, characterCount;

		// strings are equal, so unless they hit return, we won't reload the page
		eventCharacters = [event characters];
		characterCount = [eventCharacters length];
		for (characterIndex = 0; characterIndex < characterCount; characterIndex++) {
			unichar key;
			
			key = [eventCharacters characterAtIndex:characterIndex];
			
			//NSLog(@"Got key %c", key);
			switch (key) {
				case NSInsertFunctionKey:
				case NSInsertLineFunctionKey:
				case '\003': // enter
				case '\r': // return
					shouldReload = YES;
					break;
			}
		}		

		if (!shouldReload)
			return;
	}	

	NSString *urlStr = [sender stringValue];
	
	// check if it needs a prefix
	NSRange range = [urlStr rangeOfString:@"://" options:(0 & (~NSAnchoredSearch))];	
	if (!range.length)
	{
		urlStr = [NSString stringWithFormat:@"http://%@", urlStr];
	}
	
	//NSLog(@"loading url %@", urlStr);
	[self loadPageWithAddress:urlStr];
}
- (void)loadPageWithAddress:(NSString *)addr;
{
	[addressField removeFirstResponder];
	WebFrame *mainFrame = [webView mainFrame];	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:addr]];	
	[mainFrame loadRequest:request];		
}


#pragma mark Adrdress Field Delegate
- (void)controlTextDidBeginEditing:(NSNotification *)aNotification {
	//nothing for now
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
	[[self window] performSelector:@selector(makeFirstResponder:) withObject:[self window] afterDelay:0];
}

#pragma mark Notifications
- (void)progressEstimateChanged:(NSNotification *)notif {
	//NSLog(@"progress changed");
	if ([webView estimatedProgress] != 1.0) {
		[addressField setProgress:[webView estimatedProgress]];
	}
}

- (void)progressFinished:(NSNotification *)notif {
	//NSLog(@"progress finished");
	isLoading = NO;
	[self performSelector:@selector(setProgressToDone) withObject:nil afterDelay:0];
}

- (void)setProgressToDone {
	//NSLog(@" set progress finished");
	if (isLoading == NO) {
		[addressField setProgress:1.0];
	}
	[self performSelector:@selector(finishedLoading) withObject:nil afterDelay:0.15];
}

- (void)progressStarted:(NSNotification *)notif {
	//NSLog(@"progress started");
	[statusBar startProgress];
	[reloadButton setImage:[NSImage imageNamed:@"IPSWebAddressBarStopButton"]];
	isLoading = YES;
}

- (void)finishedLoading {
	//NSLog(@"finishing Loading");
	[addressField setProgress:0.0];
	if (isLoading == NO) {
		[statusBar endProgress];
		[reloadButton setImage:[NSImage imageNamed:@"IPSWebAddressBarReloadButton"]];
	}
}

#pragma mark FrameLoadDelegate
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	if (frame == [sender mainFrame])
	{
		NSString *urlStr = [[[[frame dataSource] request] URL] absoluteString];
		[addressBar setUrlString:urlStr];
	}
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
	if (frame == [sender mainFrame])
	{
		NSString *urlStr = [[[[frame provisionalDataSource] request] URL] absoluteString];
        
        // special case, clicking on screensplitr link should popup a safari
        if ([urlStr caseInsensitiveCompare:@"http://www.plutinosoft.com/screensplitr"] == NSOrderedSame) {
            [sender stopLoading:nil];
            NSWorkspace* ws = [NSWorkspace sharedWorkspace];

            NSURL* url = [NSURL URLWithString:urlStr];
            [ws openURL:url];

            return;
        }
        
		[addressBar setTitle:@"Loading..."];
		
		[addressBar setUrlString:urlStr];

		[toolbar validateBackForwardButtons];
	}
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
	if (frame == [sender mainFrame])
	{
		[addressBar setTitle:title];		
	}
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveContentLength: (unsigned)length fromDataSource:(WebDataSource *)dataSource {
	[self doScale];
}
- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
	[self doScale];
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	SEL action = [anItem action];
	if (action == @selector(toggleHideLocationBar:))
	{
		if (isLocationBarHidden)
			[anItem setTitle:@"Show Location Bar"];
		else 
			[anItem setTitle:@"Hide Location Bar"];
	} else if (action == @selector(toggleScaleToFit:))
	{
		[anItem setState:[self shouldScaleToFit] ? 1 : 0];
	}
		
	return YES;
}

@end
