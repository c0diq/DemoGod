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

#import "IPSController.h"

#import "IPSView.h"
#import "IPSWindow.h"
#import "IPSAnimationWindow.h"
#import "IPSWebContainerView.h"
#import "IPSApplication.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>

@implementation IPSController
+ (void)initialize;
{
	[IPSApplication setupDefaults];
}

- (void)awakeFromNib;
{
	[phoneWindow center];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IPSEnablePlugins"]) {
		[[webView preferences] setPlugInsEnabled:YES];
		[pluginsMenuItem setState:1];
	} else {
		[[webView preferences] setPlugInsEnabled:NO];
		[pluginsMenuItem setState:0];
	}
	//NSLog(@"awake plugins are? %i", [[webView preferences] arePlugInsEnabled]);
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IPSUsesiPhoneUserAgent"]) {
		[webView setCustomUserAgent:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A538a Safari/419.3"];
		[webKitMenuItem setState:0];
		[iPhoneMenuItem setState:1];
		[customMenuItem setState:0];
	} else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IPSUsesCustomUserAgent"]) {
		[webView setCustomUserAgent:[[NSUserDefaults standardUserDefaults] stringForKey:@"IPSCustomUserAgent"]];
		[webKitMenuItem setState:0];
		[iPhoneMenuItem setState:0];
		[customMenuItem setState:1];
	} else {
		[webView setCustomUserAgent:nil];
		[webKitMenuItem setState:1];
		[iPhoneMenuItem setState:0];
		[customMenuItem setState:0];
	}
	
    browser = [[NSNetServiceBrowser alloc] init];
    services = [[NSMutableArray array] retain];
    devices = [[NSMutableDictionary dictionary] retain];
    [browser setDelegate:self];

    // Passing in "" for the domain causes us to browse in the default browse domain,
    // which currently will always be "local".  The service type should be registered
    // with IANA, and it should be listed at <http://www.iana.org/assignments/port-numbers>.
    // At minimum, the service type should be registered at <http://www.dns-sd.org/ServiceTypes.html>
    // Our service type "wwdcpic" isn't listed because this is just sample code.
    [browser searchForServicesOfType:@"_http._tcp." inDomain:@""];
    
    server = new NPT_HttpServer(0);
    NPT_Result res = server->SetListenPort(0, false);
    NSLog(@"local server listening on: %d", server->GetPort());
    
    NSString* doc = [self getHomepageHtml];
    homePageHandler = new NPT_HttpHomePageRequestHandler([doc UTF8String]);
    server->AddRequestHandler(homePageHandler, "/home.html", false);
    
    [NSThread detachNewThreadSelector:@selector(runServerLoop:)
                             toTarget:self
                            withObject:nil];

	//NSLog(@"awake user agent: %@", [webView customUserAgent]);	
}

- (NSString*)getHomepageHtml {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"home" ofType:@"html"];
    NSString* doc = [NSString stringWithContentsOfFile: path
                                              encoding: NSUTF8StringEncoding
                                                 error:nil];
    if ([devices count] == 0) {
        doc = [doc stringByAppendingString:@"Searching for ScreenSplitr enabled iPhones..."];
    } else {                                            
        doc = [doc stringByAppendingString:@"Some iPhones were detected:<br>"];
        NSEnumerator * enumerator = [[devices allKeys] objectEnumerator];
        NSString * url;

        while (url = [enumerator nextObject]) {
            NSNetService * currentDevice = [devices objectForKey:url];
            doc = [doc stringByAppendingFormat:@"%@: <a href=\"%@/screensplitr\">ScreenSplitr</a> (<a href=\"%@/content/viewer/FLViewer_t.html\">Veency</a>)<br>", [currentDevice name], url, url];
//            doc = [doc stringByAppendingFormat:@"%@: <a href=\"%@/screensplitr\">ScreenSplitr</a> (<a href=\"%@/content/viewer/VncViewer.html\">Veency</a>)<br>", [currentDevice name], url, url];
        }
    }
    
    doc = [doc stringByAppendingString:@"</body></html>"];
}

- (BOOL)isHomePage {        
    NSString *urlStr = [[[[[webView mainFrame] provisionalDataSource] request] URL] absoluteString];
    NSRange range; range.location = 0; range.length = 16;
    if ([urlStr compare:@"http://localhost" options:NSCaseInsensitiveSearch range:range locale:nil] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

- (BOOL)isCurrentPage:(NSString*)url {
    NSString *urlStr = [[[[[webView mainFrame] provisionalDataSource] request] URL] absoluteString];
    return ([urlStr caseInsensitiveCompare:url] == NSOrderedSame);
}

- (void)reload:(BOOL)force {
    NSString* doc = [self getHomepageHtml];
    homePageHandler->SetDocument([doc UTF8String]);
    
    if (force) [phoneWindow loadPageWithAddress:[NSString stringWithFormat:@"http://localhost:%d/home.html", server->GetPort()]];
}

- (void)runServerLoop:(id)sender {
    server->Loop();
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[phoneWindow makeKeyAndOrderFront:nil];
	
	NSImage *onImage = [NSImage imageNamed:@"IPSIPhoneOnIcon"];
	[NSApp setApplicationIconImage:onImage];
	
	[webViewController setContent:webView];
    [phoneWindow loadPageWithAddress:[NSString stringWithFormat:@"http://localhost:%d/home.html", server->GetPort()]];
}

- (IBAction)toggleUserAgents:(id)sender;
{
	if (sender == webKitMenuItem) {
		[webView setCustomUserAgent:nil];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IPSUsesWebKitUserAgent"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IPSUsesiPhoneUserAgent"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IPSUsesCustomUserAgent"];
		[webKitMenuItem setState:1];
		[iPhoneMenuItem setState:0];
		[customMenuItem setState:0];
	}else if (sender == iPhoneMenuItem) {
		[webView setCustomUserAgent:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A538a Safari/419.3"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IPSUsesiPhoneUserAgent"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IPSUsesWebKitUserAgent"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IPSUsesCustomUserAgent"];
		[webKitMenuItem setState:0];
		[iPhoneMenuItem setState:1];
		[customMenuItem setState:0];
	}else {
		[webView setCustomUserAgent:[customUserAgentField stringValue]];
		[[NSUserDefaults standardUserDefaults] setValue:[customUserAgentField stringValue] forKey:@"IPSCustomUserAgent"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IPSUsesCustomUserAgent"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IPSUsesWebKitUserAgent"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IPSUsesiPhoneUserAgent"];
		[iPhoneMenuItem setState:0];
		[webKitMenuItem setState:0];
		[customMenuItem setState:1];
		[agentPanel close];
	}
	//NSLog(@"user agent: %@", [webView customUserAgent]);
}

- (IBAction)toggleAboutPanel: (id)sender;
{
	if ([aboutPanel isVisible])
	{
		[aboutPanel performClose:nil];
	}
	else
	{
		[aboutPanel center];
		[aboutPanel makeKeyAndOrderFront:nil];
	}
}

- (IBAction)toggleCustomAgentPanel: (id)sender;
{
	if ([agentPanel isVisible])
	{
		[agentPanel performClose:nil];
	}
	else
	{
		[agentPanel center];
		[agentPanel makeKeyAndOrderFront:nil];
		[customUserAgentField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"IPSCustomUserAgent"]];
	}
}

- (IBAction)togglePluginsEnabled:(id)sender; {
	if ([[webView preferences] arePlugInsEnabled]) {
		[[webView preferences] setPlugInsEnabled:NO];
		[pluginsMenuItem setState:0];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IPSEnablePlugins"];
	} else {
		[[webView preferences] setPlugInsEnabled:YES];
		[pluginsMenuItem setState:1];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IPSEnablePlugins"];		
	}
	NSLog(@"plugins are enabled? %i", [[webView preferences] arePlugInsEnabled]);
}


- (IBAction)restoreDefaults: (id)sender; {
	//NSLog(@"restore!");
	//Not being used currently
	[[NSUserDefaults standardUserDefaults] registerDefaults:[[NSUserDefaultsController sharedUserDefaultsController] initialValues]];
	[[NSUserDefaultsController sharedUserDefaultsController] revertToInitialValues:self];
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	SEL action = [anItem action];
	if (action == @selector(doToggleRotation:))
	{
		return !isRotating;
	}
	
	return YES;
}

- (IBAction)plutinosoftWebsite: (id)sender; {
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	[workspace openURL:[NSURL URLWithString:@"http://www.plutinosoft.com"]];
}
- (IBAction)pltDemoGodWebsite: (id)sender; {
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	[workspace openURL:[NSURL URLWithString:@"http://www.plutinosoft.com/demogod"]];
}
- (IBAction)pltScreenSplitrWebsite: (id)sender; {
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	[workspace openURL:[NSURL URLWithString:@"http://www.screensplitr.com"]];
}

- (IBAction)marketcircleWebsite: (id)sender; {
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	[workspace openURL:[NSURL URLWithString:@"http://www.marketcircle.com"]];
}
- (IBAction)mciPhoneyWebsite: (id)sender; {
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	[workspace openURL:[NSURL URLWithString:@"http://www.marketcircle.com/iphoney/"]];
}
- (IBAction)sfiPhoneyWebsite: (id)sender; {
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	[workspace openURL:[NSURL URLWithString:@"http://sourceforge.net/projects/iphonesimulator/"]];
}

#pragma mark -
#pragma mark Bonjour

// This object is the delegate of its NSNetServiceBrowser object. We're only interested in services-related methods,
// so that's what we'll call.
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {    
    // We need to make sure we don't have the object in the list already
    NSEnumerator * enumerator = [services objectEnumerator];
    NSNetService * currentNetService;

    while(currentNetService = [enumerator nextObject]) {
        if ([currentNetService isEqual:aNetService]) {
            return;
        }
    }
    
    [services addObject:aNetService];
    [aNetService retain];
    [aNetService setDelegate:self];
    [aNetService resolveWithTimeout:20];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    // This case is slightly more complicated. We need to find the object in the list and remove it.
    NSEnumerator * enumerator = [services objectEnumerator];
    NSNetService * currentNetService;

    while(currentNetService = [enumerator nextObject]) {
        if ([currentNetService isEqual:aNetService]) {         
            [self deviceLeft:currentNetService];
            break;
        }
    }
    //[aNetService release];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {

    if ([[sender addresses] count] > 0) {
        NSData * address;
        struct sockaddr * socketAddress;
        NSString * ipAddressString = nil;
        NSString * portString = nil;
        int socketToRemoteServer;
        char buffer[256];
        int index;

        // Iterate through addresses until we find an IPv4 address
        for (index = 0; index < [[sender addresses] count]; index++) {
            address = [[sender addresses] objectAtIndex:index];
            socketAddress = (struct sockaddr *)[address bytes];

            if (socketAddress->sa_family == AF_INET) break;
        }

        // Be sure to include <netinet/in.h> and <arpa/inet.h> or else you'll get compile errors.

        if (socketAddress) {
            switch(socketAddress->sa_family) {
                case AF_INET:
                    if (inet_ntop(AF_INET, &((struct sockaddr_in *)socketAddress)->sin_addr, buffer, sizeof(buffer))) {
                        ipAddressString = [NSString stringWithCString:buffer];
                        portString = [NSString stringWithFormat:@"%d", ntohs(((struct sockaddr_in *)socketAddress)->sin_port)];
                    }
                    
                    // Cancel the resolve now that we have an IPv4 address.
                    [sender stop];
                    [sender release];
                    serviceBeingResolved = nil;

                    break;
                case AF_INET6:
                    // PictureSharing server doesn't support IPv6
                    return;
            }
        }  
        
        NSData* txtData = [sender TXTRecordData];
        if (txtData) {
            NSDictionary* dictionary = [NSNetService dictionaryFromTXTRecordData:txtData]; 
            NSData* data = [dictionary objectForKey:@"path"];
            if (data) {
                NSString* path = [NSString stringWithCString:(const char*)[data bytes] length:[data length]];
                if ([path caseInsensitiveCompare:@"/content/home.html"] == NSOrderedSame) {
                    NSString* url = [NSString stringWithFormat:@"http://%@:%@", ipAddressString, portString];
                    NSLog(@"%@", url);
                    
                    [self deviceArrived:sender withUrl:url];
                    return;
                }
            }
        }
    }
    
    [self deviceLeft:sender];
}

- (void)deviceArrived:(NSNetService*)service withUrl:(NSString*)url {
    NSLog(@"%@", url);
    if ([devices objectForKey:url] == nil) {
        [devices setObject:service forKey:url];
        
        // reload
        //[self performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:NO];
        [self reload:[self isHomePage]];
    }
}

- (void)deviceLeft:(NSNetService*)service {   
    NSArray* urls = [devices allKeysForObject:service];
    if ([urls count] > 0) {  
        // shortcut there should be only one url per device in array
        NSString* url = [urls objectAtIndex:0];
        
        // remove all devices
        [devices removeObjectsForKeys:urls]; 
           
        // reload page and force if we were on that device
        [self reload:([self isCurrentPage:url] || [self isHomePage])];
    }
    
    // remove and reload if in our list
    if ([services indexOfObjectIdenticalTo:service]) {
        [services removeObject:service];        
    }
}

#pragma mark -
#pragma mark Rotation Animation
- (BOOL)canToggleRotation;
{
	return !isRotating;
}

- (void)configureRotationWindow {
	isRotating = YES;

	NSRect phoneFrame = [phoneWindow frame];
	NSRect rotationFrame = [rotationWindow frame];
	
	float  phoneDimension = MAX(NSWidth(phoneFrame), NSHeight(phoneFrame));
	
	// center then expand the animation window relative to the phone window
	rotationFrame = NSMakeRect(NSMidX(phoneFrame) - (phoneDimension / 2.0), NSMidY(phoneFrame) - (phoneDimension / 2.0), phoneDimension, phoneDimension);
	rotationFrame = NSInsetRect(rotationFrame, -90.0, -90.0);
	
	[rotationWindow setFrame:rotationFrame display:YES];
}

- (IBAction)doToggleRotation:(id)sender {
	if ([phoneWindow layoutMode] == IPSPortraitMode) {
		[self doRotateToLandscape:sender];
	
	} else {
		[self doRotateToPortrait:sender];
	}
}

- (IBAction)doRotateToLandscape:(id)sender {
	
	BOOL isShift = ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) != 0;	
	NSTimeInterval duration = (isShift) ? 2.5 : 0.65;
	
	[self configureRotationWindow];

	
	// load our animation, it won't be drawn until we instruct the QCView to start rendering...
	NSString *comp = [[NSBundle mainBundle] pathForResource:@"iPhoneComposition" ofType:@"qtz"];
	[rotationView setAutostartsRendering:NO];
	[rotationView loadCompositionFromFile:comp];
	
	[rotationView setValue:[[phoneWindow phoneView] currentImage] forInputKey:@"Image"];	
	[rotationWindow makeKeyAndOrderFront:nil];
	
	if (isShift) [rotationView setValue:[NSNumber numberWithInt:duration] forInputKey:@"Duration"];
	
	[rotationView startRendering];
	[rotationView display];

	[phoneWindow setAlphaValue:0.0];
	[phoneWindow setLayoutMode:IPSLandscapeMode];
	
	[self performSelector:@selector(endAnimation:) withObject:nil afterDelay:duration];
}

- (IBAction)doRotateToPortrait:(id)sender {

	BOOL isShift = ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) != 0;
	NSTimeInterval duration = (isShift) ? 2.5 : 0.65;

	[self configureRotationWindow];

	// load our animation, it won't be drawn until we instruct the QCView to start rendering...
	NSString *comp = [[NSBundle mainBundle] pathForResource:@"iPhoneCompositionToP" ofType:@"qtz"];
	[rotationView setAutostartsRendering:NO];
	[rotationView loadCompositionFromFile:comp];
	
	[rotationView setValue:[[phoneWindow phoneView] currentImage] forInputKey:@"Image"];
	[rotationWindow makeKeyAndOrderFront:nil];

	if (isShift) [rotationView setValue:[NSNumber numberWithInt:duration] forInputKey:@"Duration"];

	[rotationView startRendering];
	[rotationView display];

	[phoneWindow setAlphaValue:0.0];
	[phoneWindow setLayoutMode:IPSPortraitMode];

	[self performSelector:@selector(endAnimation:) withObject:nil afterDelay:duration + .1];
}

- (void)endAnimation:(id)sender {
	[phoneWindow setAlphaValue:1.0];

	// Otherwise the shadow seems to get confused and display a drawing glitch, so we "reset" it
	[phoneWindow setHasShadow:NO];
	[phoneWindow setHasShadow:YES];
	
	[rotationWindow fadeAndOrderOut:nil];
	
	[self performSelector:@selector(resetIsRotatingFlag) withObject:nil afterDelay:1];
}

- (void)resetIsRotatingFlag;
{
	isRotating = NO;
	[rotationWindow close];
}
@end
