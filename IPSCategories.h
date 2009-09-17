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


@interface NSImage (MCAdditions)

+ (NSImage *)imageNamed:(NSString *)imageName inBundle:(NSBundle *)aBundle;

@end

@interface NSFont (MCAdditions)
// Tries to make a font with this name and size, and if it fails makes a system font with this name and size
+ (NSFont *)safeFontWithName:(NSString *)name size:(float)size;
@end

@interface NSAttributedString (MCAdditions)
- (NSRect)drawInRectangle:(NSRect)rectangle alignment:(NSTextAlignment)alignment verticallyCentered:(BOOL)verticallyCenter;
@end

@interface NSString (MCAdditions)
+ (NSString *)horizontalEllipsisString;
@end

@interface NSCalendarDate (MCAdditions)
+ (NSString *)shortTimeString;
@end

@interface NSView(WVDPrivate) 
- (NSClipView *)firstDescendentClipView;
@end
