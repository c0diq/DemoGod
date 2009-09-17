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

#import "IPSApplication.h"


@implementation IPSApplication
+ (void)setupDefaults
{
	//NSLog(@"setup defaults!");
	NSString *userDefaultsValuesPath;
    NSDictionary *userDefaultsValuesDict;
    NSDictionary *initialValuesDict;
    NSArray *resettableUserDefaultsKeys;
	
    // load the default values for the user defaults
    userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults"
														   ofType:@"plist"];
    userDefaultsValuesDict=[NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	
    // set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
	
    // if your application supports resetting a subset of the defaults to
    // factory values, you should set those values
    // in the shared user defaults controller
    resettableUserDefaultsKeys=[NSArray arrayWithObjects:@"IPSEnablePlugins",@"IPSCustomUserAgent",@"IPSUsesiPhoneUserAgent",@"IPSUsesCustomUserAgent",@"IPSUsesWebKitUserAgent",nil];
    initialValuesDict=[userDefaultsValuesDict dictionaryWithValuesForKeys:resettableUserDefaultsKeys];
	
    // Set the initial values in the shared user defaults controller
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValuesDict];
}

- (void)terminate:(id)sender
{
	[self setApplicationIconImage:[NSImage imageNamed:@"IPSIPhoneOffIcon"]];
	[super terminate:sender];
}

@end
