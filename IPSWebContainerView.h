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


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@class IPSWebAddressBarView, IPSWebToolbarView, IPSStatusBarView, IPSWebAddressField;

@interface IPSWebContainerView : NSView {
	IBOutlet WebView *webView;
	IBOutlet IPSWebAddressBarView *addressBar;
	IBOutlet IPSWebToolbarView    *toolbar;
	
	IBOutlet NSButton *reloadButton;
	IBOutlet IPSStatusBarView *statusBar;
	IBOutlet IPSWebAddressField *addressField;

	float scaleFactor;
	
	BOOL shouldScaleToFit;
	BOOL isLocationBarHidden;
    BOOL isHomePage;

	BOOL isLoading;
	int count;
}

#pragma mark -
#pragma mark Accessors
- (BOOL)isLoading;
- (void)setIsLoading:(BOOL)inIsLoading;
- (void)doScale;

- (BOOL)shouldScaleToFit;
- (void)setShouldScaleToFit:(BOOL)aBool;

#pragma mark -
#pragma mark Action Methods
- (IBAction)stop:(id)sender;
- (IBAction)reload:(id)sender;

- (IBAction)addressFieldDidAct:(id)sender;

- (IBAction)toggleScaleToFit:(id)sender;
- (IBAction)toggleHideLocationBar:(id)sender;

- (IBAction)openLocation:(id)sender;

- (void)loadPageWithAddress:(NSString *)addr;
@end
