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


#import "IPSStatusBarView.h"
#import "IPSCategories.h"

static NSImageCell *statusBarWebBackground = nil;

static NSImage *batteryLifeFull = nil;

static NSImage *wifiStatusFull = nil;
static NSImage *wifiStatusNone = nil;

static NSImage *phoneServiceFull = nil;
static NSImage *phoneServiceEmpty = nil;

@implementation IPSStatusBarView
+ (void)initialize;
{
	// Initialize our background image
	statusBarWebBackground = [[NSImageCell alloc] initImageCell:[NSImage imageNamed:@"IPSStatusBarWebBackground"]];
	[statusBarWebBackground setImageScaling:NSScaleToFit];

	batteryLifeFull = [[NSImage imageNamed:@"IPSStatusBarBatteryFull"] copy];
	[batteryLifeFull setFlipped:YES];
	
	wifiStatusFull = [[NSImage imageNamed:@"IPSStatusBarWifiFull"] copy];
	[wifiStatusFull setFlipped:YES];
	
	wifiStatusNone = [[NSImage imageNamed:@"IPSStatusBarWifiNone"] copy];
	[wifiStatusNone setFlipped:YES];

	phoneServiceFull = [[NSImage imageNamed:@"IPSStatusBarServiceFull"] copy];
	[phoneServiceFull setFlipped:YES];
	phoneServiceEmpty = [[NSImage imageNamed:@"IPSStatusBarServiceNone"] copy];
	[phoneServiceEmpty setFlipped:YES];

}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		statusBarMode = IPSStatusBarModeWeb;
		dateSetterTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(dateSetterTimerDidFire:) userInfo:nil repeats:YES];
		[dateSetterTimer fire];
		
		progressWheel = [[NSProgressIndicator alloc] init];
		[self addSubview:progressWheel];
		[progressWheel setStyle:NSProgressIndicatorSpinningStyle];
		[progressWheel setControlSize:NSSmallControlSize];
		[progressWheel setFrame:NSMakeRect(0,0,16,16)];
		[progressWheel setHidden:YES];
		[progressWheel setUsesThreadedAnimation:YES];
		
		[self setServiceName:@"AT&T"];
    }
    return self;
}

- (void)dealloc;
{
	[dateSetterTimer invalidate];
	dateSetterTimer = nil;
	
	[timeString release];
	timeString = nil;
	
	[serviceName release];
	serviceName = nil;
	
	[super dealloc];
}

- (void)dateSetterTimerDidFire:(NSTimer *)aTimer;
{
	NSString *dateStr = [NSCalendarDate shortTimeString];
	[self setTimeString:dateStr];
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
	NSRect bounds = [self bounds];
	
	// Status bar mode for the web browser
	if (statusBarMode == IPSStatusBarModeWeb)
	{
		// Background
		[statusBarWebBackground drawWithFrame:bounds inView:self];
		
		// Time String
		[[self timeString] drawAtPoint:timePoint withAttributes:[self timeStringAttributes]];

		// Battery Life
		NSImage *bImage = batteryLifeFull; // until we display the "real" battery life we just use full as default
		[bImage drawInRect:batteryRect fromRect:NSMakeRect(0,0,[bImage size].width,[bImage size].height)
				 operation:NSCompositeSourceOver fraction:1];
		
		// Phone Service Status
		NSImage *sImage = phoneServiceFull; // until we implement something that would require this to show the empty...dunno what that could translate to on a computer though
		[sImage drawInRect:serviceRect fromRect:NSMakeRect(0,0,[sImage size].width,[sImage size].height)
				 operation:NSCompositeSourceOver fraction:1];
		
		
		// Service name
		[[self serviceName] drawAtPoint:NSMakePoint(serviceNameRect.origin.x,serviceNameRect.origin.y) withAttributes:[self serviceAttributes]];
		
		
		// Wifi indicator
		NSImage *wifiImage = wifiStatusFull; // until we implement something to set this according to the actual wifi status of the computer
		[wifiImage drawInRect:wifiRect fromRect:NSMakeRect(0,0,[wifiImage size].width,[wifiImage size].height)
				 operation:NSCompositeSourceOver fraction:1];
	}

	// Put additional modes here...none implemented yet!
}

- (BOOL)isFlipped;
{
	return YES;
}

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	[self layout];
}

- (void)setFrameSize:(NSSize)newSize {
	[super setFrameSize:newSize];
	[self layout];
}

- (void)layout{
	NSRect bounds = [self bounds];
	
	//Sime string
	NSSize textSize = [[self timeString] sizeWithAttributes:[self timeStringAttributes]];
	float x = round(([self bounds].size.width / 2) - (textSize.width / 2));
	timePoint = NSMakePoint(x,1);
		
	// Battery Life
	NSImage *bImage = batteryLifeFull; // until we display the "real" battery life we just use full as default
	
	batteryRect = NSMakeRect(bounds.origin.x + bounds.size.width - 5 - [bImage size].width,
									bounds.origin.y + 2,
									[bImage size].width,[bImage size].height);
		
	// Phone Service Status
	NSImage *sImage = phoneServiceFull; // until we implement something that would require this to show the empty...dunno what that could translate to on a computer though
	serviceRect = NSMakeRect(bounds.origin.x + 5,
									bounds.origin.y + 3,
									[sImage size].width,[sImage size].height);
		
	
	// Service name
	NSSize nameSize = [[self serviceName] sizeWithAttributes:[self serviceAttributes]];
	
	serviceNameRect = NSMakeRect(serviceRect.origin.x + serviceRect.size.width + 3,2,nameSize.width,nameSize.height);
		
	
	// Wifi indicator
	NSImage *wifiImage = wifiStatusFull; // until we implement something to set this according to the actual wifi status of the computer
	wifiRect = NSMakeRect(serviceNameRect.origin.x + serviceNameRect.size.width + 8,
								 bounds.origin.y + 3,
								 [wifiImage size].width,[wifiImage size].height);
}

- (void)startProgress {
	//position
	NSRect bounds = [self bounds];
	wheelRect = NSMakeRect(wifiRect.origin.x + wifiRect.size.width + 7,
								  bounds.origin.y +1,
								  [progressWheel bounds].size.width,[progressWheel bounds].size.height);
	[progressWheel setFrame:wheelRect];	
	[progressWheel setHidden:NO];
	[progressWheel setUsesThreadedAnimation:YES];
	[progressWheel startAnimation:nil];
}

- (void)endProgress {
	[progressWheel stopAnimation:nil];
	[progressWheel setHidden:YES];
}

#pragma mark Accessors
- (NSString *)timeString
{
    return timeString; 
}
- (void)setTimeString:(NSString *)aTimeString
{
    [aTimeString retain];
    [timeString release];
    timeString = aTimeString;
	[self layout];
}

- (NSDictionary *)timeStringAttributes;
{
	static NSDictionary *_timeStringAttributes = nil;
	if (!_timeStringAttributes)
	{
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(0,-1)];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:1 alpha:1.0]];
		
		_timeStringAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont safeFontWithName:@"Helvetica-Bold" size:12],NSFontAttributeName,
			[NSColor colorWithCalibratedWhite:.21176 alpha:1],NSForegroundColorAttributeName,shadow,NSShadowAttributeName,nil] retain];
	}
	
	return _timeStringAttributes;
}

- (NSString *)serviceName
{
    return serviceName; 
}
- (void)setServiceName:(NSString *)aServiceName
{
    [aServiceName retain];
    [serviceName release];
    serviceName = aServiceName;
	[self layout];
}

- (NSDictionary *)serviceAttributes;
{
	static NSDictionary *_serviceAttributes = nil;
	if (!_serviceAttributes)
	{
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(0,-1)];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:1 alpha:1.0]];
		
		_serviceAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont safeFontWithName:@"Helvetica-Bold" size:12],NSFontAttributeName,
			[NSColor colorWithCalibratedRed:0.3843 green:0.3843 blue:0.3843 alpha:1.0],NSForegroundColorAttributeName,shadow,NSShadowAttributeName,nil] retain];
	}
	
	return _serviceAttributes;	
}
@end
