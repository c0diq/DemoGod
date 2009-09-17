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


#import "IPSWebAddressFieldCell.h"
#import "IPSWebAddressField.h"

static NSImageCell *background = nil;
static NSImageCell *leftCap = nil;
static NSImageCell *rightCap = nil;
static NSImageCell *backgroundLoading = nil;
static NSImageCell *leftCapLoading = nil;
static NSImageCell *rightCapLoading = nil;

@implementation IPSWebAddressFieldCell
+ (void)initialize;
{
	// Initialize our background image
	background = [[NSImageCell alloc] initImageCell:[NSImage imageNamed:@"IPSWebAddressFieldBackground"]];
	[background setImageScaling:NSScaleToFit];		

	leftCap = [[NSImageCell alloc] initImageCell:[NSImage imageNamed:@"IPSWebAddressFieldLeftCap"]];
	rightCap = [[NSImageCell alloc] initImageCell:[NSImage imageNamed:@"IPSWebAddressFieldRightCap"]];
	
	backgroundLoading = [[NSImageCell alloc] initImageCell:[NSImage imageNamed:@"IPSWebAddressBarLoadingBackground"]];
	[backgroundLoading setImageScaling:NSScaleToFit];		
	
	leftCapLoading = [[NSImageCell alloc] initImageCell:[NSImage imageNamed:@"IPSWebAddressFieldLoadingLeftCap"]];
	rightCapLoading = [[NSImageCell alloc] initImageCell:[NSImage imageNamed:@"IPSWebAddressFieldLoadingRightCap"]];
}

- (id) init {
	self = [super init];
	if (self != nil) {
		progressRect = NSZeroRect;
	}
	return self;
}


- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{	
	IPSWebAddressField *addressField = (IPSWebAddressField *)controlView;
	BOOL addressFieldIsBeingEdited = [[[addressField window] fieldEditor:NO forObject:nil] delegate] == addressField;
	if (([addressField progress] > 0.0) && !addressFieldIsBeingEdited ) {
		
		progressRect = NSMakeRect(cellFrame.origin.x + 10, cellFrame.origin.y,cellFrame.size.width - 20,cellFrame.size.height);
		progressRect.size.width = progressRect.size.width * [addressField progress];
		
		[backgroundLoading drawWithFrame:progressRect inView:controlView];
		
		NSRect bgRect = NSMakeRect(progressRect.origin.x + progressRect.size.width, cellFrame.origin.y,cellFrame.size.width - 20 - progressRect.size.width,cellFrame.size.height);
		[background drawWithFrame:bgRect inView:controlView];
		
		NSRect leftCapRect = NSMakeRect(cellFrame.origin.x,cellFrame.origin.y,10,32);
		[leftCapLoading drawWithFrame:leftCapRect inView:controlView];
		
		if ([addressField progress] == 1.0) {
			NSRect rightCapRect = NSMakeRect(cellFrame.origin.x + cellFrame.size.width - 10,cellFrame.origin.y,10,32);
			[rightCapLoading drawWithFrame:rightCapRect inView:controlView];
		} else {
			NSRect rightCapRect = NSMakeRect(cellFrame.origin.x + cellFrame.size.width - 10,cellFrame.origin.y,10,32);
			[rightCap drawWithFrame:rightCapRect inView:controlView];
		}

	}
	else {
		NSRect bgRect = NSMakeRect(cellFrame.origin.x + 10, cellFrame.origin.y,cellFrame.size.width - 20,cellFrame.size.height);
		[background drawWithFrame:bgRect inView:controlView];
		
		NSRect leftCapRect = NSMakeRect(cellFrame.origin.x,cellFrame.origin.y,10,32);
		[leftCap drawWithFrame:leftCapRect inView:controlView];
		
		NSRect rightCapRect = NSMakeRect(cellFrame.origin.x + cellFrame.size.width - 10,cellFrame.origin.y,10,32);
		[rightCap drawWithFrame:rightCapRect inView:controlView];
	}
	
	[super drawWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSRect textRect = NSMakeRect(cellFrame.origin.x+10,cellFrame.origin.y + 8,cellFrame.size.width - 20,cellFrame.size.height - 8);
	[super drawInteriorWithFrame:textRect inView:controlView];
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{
	NSRect textRect = NSMakeRect(aRect.origin.x+10,aRect.origin.y + 8,aRect.size.width - 20,aRect.size.height - 8);
	[super editWithFrame:textRect inView:controlView editor:textObj delegate:anObject event:theEvent];
}
- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{
	NSRect textRect = NSMakeRect(aRect.origin.x+10,aRect.origin.y + 8,aRect.size.width - 20,aRect.size.height - 8);

	[super selectWithFrame:textRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj
{
	NSText *fieldEditor = [super setUpFieldEditorAttributes:textObj];

	[fieldEditor setDrawsBackground:NO];

	return fieldEditor;
}

@end
