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

typedef enum _IPSStatusBarMode {
	IPSStatusBarModeWeb     = 0
} IPSStatusBarMode;


@interface IPSStatusBarView : NSView {
	NSString *timeString;
	NSTimer *dateSetterTimer;
	NSProgressIndicator *progressWheel;
	
	NSRect wifiRect;
	NSRect serviceNameRect;
	NSRect serviceRect;
	NSRect batteryRect;
	NSRect wheelRect;
	NSPoint timePoint;
	
	IPSStatusBarMode statusBarMode;

	NSString *serviceName;
}

- (void)startProgress;
- (void)endProgress;
- (void)layout;


#pragma mark Accessors
- (NSString *)timeString;
- (void)setTimeString:(NSString *)aTimeString;

- (NSDictionary *)timeStringAttributes;

- (NSString *)serviceName;
- (void)setServiceName:(NSString *)aServiceName;
- (NSDictionary *)serviceAttributes;

@end
