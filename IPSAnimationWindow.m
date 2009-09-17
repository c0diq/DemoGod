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


#import "IPSAnimationWindow.h"


@implementation IPSAnimationWindow

- (id)initWithContentRect:(NSRect)contentRect 
                styleMask:(unsigned int)aStyle 
                  backing:(NSBackingStoreType)bufferingType 
                    defer:(BOOL)flag {
    
    if (self = [super initWithContentRect:contentRect 
								styleMask:NSBorderlessWindowMask 
								  backing:NSBackingStoreBuffered 
									defer:NO]) {
        [self setLevel: NSNormalWindowLevel];
        [self setBackgroundColor: [NSColor clearColor]];
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
        [self setHasShadow:YES];
        
        return self;
    }
    
    return nil;
}

- (void)makeKeyAndOrderFront:(id)sender {
	[self setAlphaValue:1.0];	
	[super makeKeyAndOrderFront:sender];
}

- (void)fadeAndOrderFront:(id)sender {
	[[[[NSViewAnimation alloc] initWithViewAnimations:
		[NSArray arrayWithObject:
			[NSDictionary dictionaryWithObjectsAndKeys:
				self, NSViewAnimationTargetKey,
				NSViewAnimationFadeInEffect, NSViewAnimationEffectKey,
				nil]]] 
		autorelease]
		startAnimation];
}

- (void)fadeAndOrderOut:(id)sender {
	[[[[NSViewAnimation alloc] initWithViewAnimations:
		[NSArray arrayWithObject:
			[NSDictionary dictionaryWithObjectsAndKeys:
				self, NSViewAnimationTargetKey,
				NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey,
				nil]]] 
		autorelease]
		startAnimation];
}

@end
