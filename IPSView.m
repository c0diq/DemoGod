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


#import "IPSView.h"
#import "IPSWIndow.h"

#import "IPSCategories.h"


static NSImage*          IPSBackgroundImage_Portrait = nil;
static NSImage*          IPSBackgroundImage_Landscape = nil;

@implementation IPSView

+ (void)initialize;
{
	NSBundle *bundle = [NSBundle bundleForClass:self];
	
	
	IPSBackgroundImage_Portrait = [[NSImage imageNamed:@"IPSIPhone_Portrait" inBundle:bundle] retain];
	IPSBackgroundImage_Landscape = [[NSImage imageNamed:@"IPSIPhone_Landscape" inBundle:bundle] retain];
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
//	[NSBezierPath fillRect:[self bounds]];
	NSImage *image = ([(IPSWindow *)[self window] layoutMode] == IPSPortraitMode) ? IPSBackgroundImage_Portrait : IPSBackgroundImage_Landscape;
	[image compositeToPoint:[self bounds].origin operation:NSCompositeSourceOver];	
}

#pragma mark -
#pragma mark Animation Support
- (NSImage *)currentImage {
	NSImage *currentImage = [[[NSImage alloc] initWithSize:[self bounds].size] autorelease];
	
	[currentImage lockFocus];
	[self displayRectIgnoringOpacity:[self bounds] inContext:[NSGraphicsContext currentContext]];
	[currentImage unlockFocus];
	
	return currentImage;
}

@end
