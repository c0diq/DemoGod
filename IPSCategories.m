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


#import "IPSCategories.h"


@implementation NSImage (MCAdditions)

+ (NSImage *)imageNamed:(NSString *)imageName inBundle:(NSBundle *)aBundle;
{
    NSImage *image;
    NSString *path;
	
    image = [NSImage imageNamed:imageName];
    if (image && [image size].width != 0)
        return image;
	
    path = [aBundle pathForImageResource:imageName];
    if (!path)
        return nil;
	
    image = [[NSImage alloc] initWithContentsOfFile:path];
    [image setName:imageName];
	
    return image;
}

@end

@implementation NSFont (MCAdditions)
// Tries to make a font with this name and size, and if it fails makes a system font with this name and size
+ (NSFont *)safeFontWithName:(NSString *)name size:(float)size;
{
	NSFont *fnt = [NSFont fontWithName:name size:size];
	if (!fnt)
		fnt = [NSFont systemFontOfSize:size];
	
	return fnt;
}
@end

@implementation NSAttributedString (MCAdditions)
- (NSRect)drawInRectangle:(NSRect)rectangle alignment:(NSTextAlignment)alignment verticallyCentered:(BOOL)verticallyCenter;
{
    // ASSUMPTION: This is for one line
	// ASSUMPTION: We're drawing into a flipped view!
	
    static NSTextStorage *showStringTextStorage = nil;
    static NSLayoutManager *showStringLayoutManager = nil;
    static NSTextContainer *showStringTextContainer = nil;
	
    NSRange drawGlyphRange;
    NSRange lineCharacterRange;
    NSRect lineFragmentRect;
    NSSize lineSize;
    NSString *ellipsisString;
    NSSize ellipsisSize;
    NSDictionary *ellipsisAttributes;
    BOOL requiresEllipsis;
    BOOL lineTooLong;
	
    if ([self length] == 0)
        return NSZeroRect;
	
    if (showStringTextStorage == nil) {
        showStringTextStorage = [[NSTextStorage alloc] init];
		
        showStringLayoutManager = [[NSLayoutManager alloc] init];
        [showStringTextStorage addLayoutManager:showStringLayoutManager];
		
        showStringTextContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(1.0e7, 1.0e7)];
        [showStringTextContainer setLineFragmentPadding:0.0];
        [showStringLayoutManager addTextContainer:showStringTextContainer];
    }
    
    [showStringTextStorage setAttributedString:self];
    
    lineFragmentRect = [showStringLayoutManager lineFragmentUsedRectForGlyphAtIndex:0 effectiveRange:&drawGlyphRange];
    lineSize = lineFragmentRect.size;
    lineTooLong = lineSize.width > NSWidth(rectangle);
    lineCharacterRange = [showStringLayoutManager characterRangeForGlyphRange:drawGlyphRange actualGlyphRange:NULL];
    requiresEllipsis = lineTooLong || NSMaxRange(lineCharacterRange) < [self length];
    
    if (requiresEllipsis) {
        unsigned int ellipsisAttributeCharacterIndex;
        if (lineCharacterRange.length != 0)
            ellipsisAttributeCharacterIndex = NSMaxRange(lineCharacterRange) - 1;
        else
            ellipsisAttributeCharacterIndex = 0;
        ellipsisAttributes = [self attributesAtIndex:ellipsisAttributeCharacterIndex longestEffectiveRange:NULL inRange:NSMakeRange(0, 1)];
        ellipsisString = [NSString horizontalEllipsisString];
        ellipsisSize = [ellipsisString sizeWithAttributes:ellipsisAttributes];
		
        if (lineTooLong || lineSize.width + ellipsisSize.width > NSWidth(rectangle)) {
            drawGlyphRange.length = [showStringLayoutManager glyphIndexForPoint:NSMakePoint(NSWidth(rectangle) - ellipsisSize.width, 0.5 * lineSize.height) inTextContainer:showStringTextContainer];
			
            if (drawGlyphRange.length == 0) {
                // We couldn't fit any characters with the ellipsis, so try drawing some without it (rather than drawing nothing)
                requiresEllipsis = NO;
                drawGlyphRange.length = [showStringLayoutManager glyphIndexForPoint:NSMakePoint(NSWidth(rectangle), 0.5 * lineSize.height) inTextContainer:showStringTextContainer];
            }
            lineSize.width = [showStringLayoutManager locationForGlyphAtIndex:NSMaxRange(drawGlyphRange)].x;
        }
        if (requiresEllipsis) // NOTE: Could have been turned off if the ellipsis didn't fit
            lineSize.width += ellipsisSize.width;
    } else {
        // Make the compiler happy, since it doesn't know we're not going to take the requiresEllipsis branch later
        ellipsisString = nil;
        ellipsisSize = NSMakeSize(0, 0);
        ellipsisAttributes = nil;
    }
	
    if (drawGlyphRange.length) {
        NSPoint drawPoint;
		
        // determine drawPoint based on alignment
        drawPoint.y = NSMinY(rectangle);
        switch (alignment) {
            default:
            case NSLeftTextAlignment:
                drawPoint.x = NSMinX(rectangle);
                break;
            case NSCenterTextAlignment:
                drawPoint.x = NSMidX(rectangle) - lineSize.width / 2.0;
                break;
            case NSRightTextAlignment:
                drawPoint.x = NSMaxX(rectangle) - lineSize.width;
                break;
        }
        
        if (verticallyCenter)
            drawPoint.y = NSMidY(rectangle) - lineSize.height / 2.0;
		
        [showStringLayoutManager drawGlyphsForGlyphRange:drawGlyphRange atPoint:drawPoint];
        if (requiresEllipsis) {
            drawPoint.x += lineSize.width - ellipsisSize.width;
			[ellipsisString drawAtPoint:drawPoint withAttributes:ellipsisAttributes];
        }
		
		return NSMakeRect(drawPoint.x,drawPoint.y,lineSize.width,lineSize.height);
    }
	
	return NSZeroRect;
}
@end

@implementation NSString (MCAdditions)
+ (NSString *)horizontalEllipsisString;
{
	static NSString *string = nil;
	
    if (!string)
		string = [[NSString stringWithFormat:@"%C",0x2026] retain];
	
    return string;	
}
@end

@implementation NSCalendarDate (MCAdditions)
+ (NSString *)shortTimeString;
{
	NSString *timeStr = [[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%I:%M %p"];
	if ([timeStr hasPrefix:@"0"])
		timeStr = [timeStr substringFromIndex:1];
	return timeStr;
}
@end

@implementation NSView(WVDPrivate) 
- (NSClipView *)firstDescendentClipView {
	id view = nil;
	NSEnumerator *viewEnum = nil;
	
	viewEnum = [[self subviews] objectEnumerator];
	while ((view = [viewEnum nextObject])) {
		if ([view isKindOfClass:[NSClipView class]]) {
			return view;
		}
	}
	viewEnum = [[self subviews] objectEnumerator];
	while ((view = [viewEnum nextObject])) {
		id subview = [view firstDescendentClipView];
		if (subview != nil) {
			return subview;
		}
	}
	return nil;
}
@end
