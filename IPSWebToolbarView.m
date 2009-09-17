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


#import "IPSWebToolbarView.h"

static NSImageCell *webToolbarBackground = nil;

@implementation IPSWebToolbarView
+ (void)initialize;
{
	// Initialize our background image
	webToolbarBackground = [[NSImageCell alloc] initImageCell:[NSImage imageNamed:@"IPSWebToolbarBackground"]];
	[webToolbarBackground setImageScaling:NSScaleToFit];	
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib;
{
	// -----------------------------------------------------------------------------
	// Back Button
	[backButton setBordered:NO];
	[[backButton cell] setHighlightsBy:NSNoCellMask];
	[backButton setImagePosition:NSImageOnly];
	[backButton setImage:[NSImage imageNamed:@"IPSWebToolbarBackButton"]];
	[backButton setFocusRingType:NSFocusRingTypeNone];

	// -----------------------------------------------------------------------------
	// Forward Button
	[forwardButton setBordered:NO];
	[[forwardButton cell] setHighlightsBy:NSNoCellMask];
	[forwardButton setImagePosition:NSImageOnly];
	[forwardButton setImage:[NSImage imageNamed:@"IPSWebToolbarForwardButton"]];
	[forwardButton setFocusRingType:NSFocusRingTypeNone];

	// -----------------------------------------------------------------------------
	// Bookmarks Button
	[bookmarksButton setBordered:NO];
	[[bookmarksButton cell] setHighlightsBy:NSNoCellMask];
	[bookmarksButton setImagePosition:NSImageOnly];
	[bookmarksButton setImage:[NSImage imageNamed:@"IPSWebToolbarBookmarksButton"]];
	[bookmarksButton setEnabled:NO]; // no functionality for this action right now...
	[bookmarksButton setFocusRingType:NSFocusRingTypeNone];

	// -----------------------------------------------------------------------------
	// Screen Button
	[screensButton setBordered:NO];
	[[screensButton cell] setHighlightsBy:NSNoCellMask];
	[screensButton setImagePosition:NSImageOnly];
	[screensButton setImage:[NSImage imageNamed:@"IPSWebToolbarScreensButton"]];
	[screensButton setEnabled:NO]; // no functionality for this action right now...
	[screensButton setFocusRingType:NSFocusRingTypeNone];
	
}

- (void)drawRect:(NSRect)rect {
	[webToolbarBackground drawWithFrame:[self bounds] inView:self];
}

- (void)validateBackForwardButtons;
{
//	BOOL canGoBack = [webView canGoBack];
//	BOOL canGoForward = [webView canGoForward];
//	
//	NSLog(@"WebView: %@  Can go back: %i  can go forward: %i",webView,canGoBack,canGoForward);
//	[backButton setEnabled:canGoBack];
//	[forwardButton setEnabled:canGoForward];
}
@end
