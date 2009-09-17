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
#import <Quartz/Quartz.h>
#import <WebKit/WebKit.h>
#import "Neptune.h"

/*----------------------------------------------------------------------
|   NPT_HttpHomePageRequestHandler
+---------------------------------------------------------------------*/
class NPT_HttpHomePageRequestHandler : public NPT_HttpStaticRequestHandler
{
public:
    // constructors
    NPT_HttpHomePageRequestHandler(const char* document) :
        NPT_HttpStaticRequestHandler(document) {}
    
    // public methods
    void SetDocument(const char* document) {
        NPT_AutoLock lock(m_Lock);
        m_Buffer.SetData((const NPT_Byte*)document, NPT_StringLength(document));
    }

    // NPT_HttpRequetsHandler methods
    virtual NPT_Result SetupResponse(NPT_HttpRequest&              request, 
                                     const NPT_HttpRequestContext& context,
                                     NPT_HttpResponse&             response) {
        NPT_AutoLock lock(m_Lock);
        return NPT_HttpStaticRequestHandler::SetupResponse(request, context, response);
    }

private:
    NPT_Mutex m_Lock;
};

@class IPSWindow, IPSAnimationWindow;

@interface IPSController : NSObject {
	IBOutlet IPSAnimationWindow*	rotationWindow;
	IBOutlet QCView*				rotationView;
	
	IBOutlet IPSWindow*				phoneWindow;
	IBOutlet WebView*				webView;
	
	IBOutlet NSWindow*              aboutPanel;
	
	IBOutlet NSPanel*				agentPanel;
	
	IBOutlet NSObjectController*	webViewController;	
	IBOutlet NSTextField*			customUserAgentField;
	IBOutlet NSMenuItem*			webKitMenuItem;
	IBOutlet NSMenuItem*			iPhoneMenuItem;
	IBOutlet NSMenuItem*			customMenuItem;
	IBOutlet NSMenuItem*			pluginsMenuItem;	

    NSNetServiceBrowser*            browser;
    NSMutableArray*                 services;
    NSMutableDictionary*            devices;
    NSNetService*                   serviceBeingResolved;
    
    NPT_HttpServer*                 server;
    NPT_HttpHomePageRequestHandler* homePageHandler;

	BOOL isRotating;
}
- (IBAction)toggleUserAgents:(id)sender;
- (IBAction)toggleAboutPanel: (id)sender;
- (IBAction)toggleCustomAgentPanel: (id)sender;
- (IBAction)togglePluginsEnabled:(id)sender;
- (IBAction)restoreDefaults: (id)sender;

- (IBAction)marketcircleWebsite: (id)sender;
- (IBAction)mciPhoneyWebsite: (id)sender;
- (IBAction)sfiPhoneyWebsite: (id)sender;
- (IBAction)plutinosoftWebsite: (id)sender;
- (IBAction)pltDemoGodWebsite: (id)sender;
- (IBAction)pltScreenSplitrWebsite: (id)sender;

#pragma mark -
#pragma mark Bonjour
- (NSString*)getHomepageHtml;
- (void)deviceArrived:(NSNetService*)service withUrl:(NSString*)url;
- (void)deviceLeft:(NSNetService*)service;
- (void)reload:(BOOL)force;

#pragma mark -
#pragma mark Rotation Animation
- (void)resetIsRotatingFlag;
- (BOOL)canToggleRotation;

- (void)configureRotationWindow;
- (IBAction)doToggleRotation:(id)sender;
- (IBAction)doRotateToLandscape:(id)sender;
- (IBAction)doRotateToPortrait:(id)sender;
@end
