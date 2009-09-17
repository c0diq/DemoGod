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


#import "IPSWebAddressBarView.h"
#import "IPSCategories.h"
#import "IPSWebAddressField.h"

static NSImageCell *webAddressBarBackground = nil;

@implementation IPSWebAddressBarView
+ (void)initialize;
{
	// Initialize our background image
	webAddressBarBackground = [[NSImageCell alloc] initImageCell:[NSImage imageNamed:@"IPSWebAddressBarBackground"]];
	[webAddressBarBackground setImageScaling:NSScaleToFit];	
}


- (void)awakeFromNib;
{
	// -----------------------------------------------------------------------------
	// Plus Button
	[plusButton setBordered:NO];
	[[plusButton cell] setHighlightsBy:NSNoCellMask];
	[plusButton setImagePosition:NSImageOnly];
	[plusButton setImage:[NSImage imageNamed:@"IPSWebAddressBarPlusButton"]];
	[plusButton setEnabled:NO]; // no functionality for this action right now...
	[plusButton setFocusRingType:NSFocusRingTypeNone];
	
	// -----------------------------------------------------------------------------
	// Reload Button
	[reloadButton setBordered:NO];
	[[reloadButton cell] setHighlightsBy:NSNoCellMask];
	[reloadButton setImagePosition:NSImageOnly];
	[reloadButton setImage:[NSImage imageNamed:@"IPSWebAddressBarReloadButton"]];
	[reloadButton setFocusRingType:NSFocusRingTypeNone];
	
	// -----------------------------------------------------------------------------
	// Address Field
	[addressField setFocusRingType:NSFocusRingTypeNone];
	
	[titleField setTextColor:[NSColor colorWithCalibratedRed:0.32941 green:0.38824 blue:0.43922 alpha:1.0]];
	[titleField setFont:[NSFont safeFontWithName:@"Helvetica-Bold" size:12]];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	// Draw the background
	[webAddressBarBackground drawWithFrame:[self bounds] inView:self];
}


- (IPSWebAddressField *)addressField {
	return addressField;
}

#pragma mark Accessors
- (NSDictionary *)titleAttributes;
{
	static NSDictionary *_titleAttributes = nil;
	
	if (!_titleAttributes)
	{
		// Set up the title attributes
		NSShadow *titleShadow = [[[NSShadow alloc] init] autorelease];
		[titleShadow setShadowOffset:NSMakeSize(0,-1)];
		[titleShadow setShadowColor:[NSColor colorWithCalibratedRed:0.74510 green:0.79610 blue:0.83922 alpha:1.0]];
		
		_titleAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont safeFontWithName:@"Helvetica-Bold" size:12],NSFontAttributeName,
			[NSColor colorWithCalibratedRed:0.32941 green:0.38824 blue:0.43922 alpha:1.0],NSForegroundColorAttributeName,titleShadow,NSShadowAttributeName,nil] retain];
	}

	return _titleAttributes;
}

- (void)setUrlString:(NSString *)str;
{
	[addressField setStringValue:str];
}

- (NSString *)title
{
    return title; 
}
- (void)setTitle:(NSString *)aTitle
{
	[titleField setStringValue:aTitle];
	
    [aTitle retain];
    [title release];
    title = aTitle;

	[self setNeedsDisplay:YES];
}


@end
