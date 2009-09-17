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


#import "IPSWindow.h"
#import "IPSScreenView.h"
#import "IPSWebContainerView.h"

@implementation IPSWindow

- (BOOL) canBecomeKeyWindow
{
    return YES;
}

- (void)loadPageWithAddress:(NSString *)addr;
{
    [containerView loadPageWithAddress:addr];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint currentLocation;
    NSPoint newOrigin;
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [self frame];
    
    currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
    
    if( (newOrigin.y + windowFrame.size.height) > (NSMaxY(screenFrame) - [NSMenuView menuBarHeight]) ){
        // Prevent dragging into the menu bar area
		newOrigin.y = NSMaxY(screenFrame) - windowFrame.size.height - [NSMenuView menuBarHeight];
    }
    /*
	 if (newOrigin.y < NSMinY(screenFrame)) {
		 // Prevent dragging off bottom of screen
		 newOrigin.y = NSMinY(screenFrame);
	 }
	 if (newOrigin.x < NSMinX(screenFrame)) {
		 // Prevent dragging off left of screen
		 newOrigin.x = NSMinX(screenFrame);
	 }
	 if (newOrigin.x > NSMaxX(screenFrame) - windowFrame.size.width) {
		 // Prevent dragging off right of screen
		 newOrigin.x = NSMaxX(screenFrame) - windowFrame.size.width;
	 }
	 */
    
    [self setFrameOrigin:newOrigin];
}


- (void)mouseDown:(NSEvent *)theEvent
{    
    NSRect windowFrame = [self frame];
    
    // Get mouse location in global coordinates
    initialLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
    initialLocation.x -= windowFrame.origin.x;
    initialLocation.y -= windowFrame.origin.y;
}

- (IPSView *)phoneView {
	return phoneView;
}

- (IPSLayoutMode)layoutMode {
	return layoutMode;
}
- (void)setLayoutMode:(IPSLayoutMode)aMode {
	if (layoutMode != aMode) {
		layoutMode = aMode;
		
		if (layoutMode == IPSPortraitMode) {
			[self configPortraitMode];
		} else {
			[self configLandscapeMode];
		}
	}
}


- (void)configPortraitMode {
	// FIXME: restructures the phone view to display in portrait, sizes and repositions the window appropriately
	// are we already in portrait mode? let's check our frame
	NSRect f = [self frame];
	if (f.size.width > f.size.height) // width is greater than the height so we're in landscape right now, let's go ahead and change it
	{
		NSRect phoneViewBounds = [phoneView bounds];
		
		// -----------------------------------------------------------------------------
		// IPSWindow frame
		float width = f.size.height; // width is now current height
		float height = f.size.width; // height is now current width		
									 // y = current + (height - width / 2)
		float y = f.origin.y - roundf( (f.size.width - f.size.height) / 2 );
		// x = current - (height - width / 2)
		float x = f.origin.x + roundf( (f.size.width - f.size.height) / 2 );
		
		NSRect sf = [screenView frame];
		
		// Set the window frame
		[self setFrame:NSMakeRect(x,y,width,height) display:YES];
		
		// -----------------------------------------------------------------------------
		// IPSScreenView frame
		float sfWidth = sf.size.height;
		float sfHeight = sf.size.width;

		float sfX = sf.origin.y;
		float sfY = phoneViewBounds.size.width - (sf.origin.x + sf.size.width);
		
		// Set the screenview frame
		//[screenView setFrame:NSMakeRect(sfX,sfY,sfWidth,sfHeight)];		
		[phoneView setNeedsDisplay:YES];
		//[containerView doScale];
        NSPoint newOrigin; newOrigin.x = sfX; newOrigin.y = sfY + sf.size.width;
        [screenView setFrameOrigin: newOrigin];
        [screenView setFrameRotation: 0];
	}
}

- (void)configLandscapeMode {
	// FIXME: restructures the phone view to display in landscape, sizes and repositions the window appropriately
	// are we already in landscape mode? let's check our frame
	NSRect f = [self frame];
	if (f.size.width < f.size.height) // width is less than the height so we're in portrait right now, let's go ahead and change it
	{
		NSRect phoneViewBounds = [phoneView bounds];
		
		// -----------------------------------------------------------------------------
		// IPSWindow frame
		float width = f.size.height; // width is now current height
		float height = f.size.width; // height is now current width		
		// y = current + (height - width / 2)
		float y = f.origin.y + roundf( (f.size.height - f.size.width) / 2 );
		// x = current - (height - width / 2)
		float x = f.origin.x - roundf( (f.size.height - f.size.width) / 2 );

		NSRect sf = [screenView frame];

		// Set the window frame
		[self setFrame:NSMakeRect(x,y,width,height) display:YES];
		
		// -----------------------------------------------------------------------------
		// IPSScreenView frame
		float sfWidth = sf.size.height;
		float sfHeight = sf.size.width;
		
		float sfY = sf.origin.x;
		float sfX = phoneViewBounds.size.height - (sf.origin.y + sf.size.height);
		
		// Set the screenview frame
		//[screenView setFrame:NSMakeRect(sfX,sfY,sfWidth,sfHeight)];
		
		[phoneView setNeedsDisplay:YES];

		//[containerView doScale];
        
        NSPoint newOrigin; newOrigin.x = sfX+sfWidth; newOrigin.y = sfY;
        [screenView setFrameOrigin: newOrigin];
        [screenView setFrameRotation: 90];
	}	
}

@end
