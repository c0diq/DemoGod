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


#import "IPSWebAddressField.h"
#import "IPSWebAddressFieldCell.h"

@implementation IPSWebAddressField
+ (void)initialize;
{
}

- (id)initWithCoder:(NSCoder *)decoder
{
	[(NSKeyedUnarchiver *)decoder setClass:[IPSWebAddressFieldCell class] forClassName:@"NSTextFieldCell"];

	self = [super initWithCoder:decoder];

	[(NSKeyedUnarchiver *)decoder setClass:[NSTextFieldCell class] forClassName:@"NSTextFieldCell"];

	[self setBezeled:NO];
	[self setDrawsBackground:NO];
	
	[self setFont:[NSFont fontWithName:@"Helvetica" size:14]];
	[self setTextColor:[NSColor colorWithCalibratedWhite:.5647 alpha:1]];
	
	return self;
}

- (double)progress
{
    return progress;
}

- (void)setProgress:(double)inProgress
{
    if (inProgress > 1.0) {
		inProgress = 1.0;
	} else if (inProgress < 0.0) {
		inProgress = 0.0;
	}

	progress = inProgress;
	[self setNeedsDisplay];
}

- (void)removeFirstResponder {
	id firstResponder = [[self window] firstResponder];
	if (firstResponder == self) {
		[[self window] makeFirstResponder:[self window]];
		NSLog(@"change FR in adress field");
	}
}

@end
