//
//  CGUpnpAvServer.m
//  CyberLink for C
//
//  Created by Satoshi Konno on 08/07/02.
//  Copyright 2008 Satoshi Konno. All rights reserved.
//

#include <cybergarage/upnp/std/av/cmediarenderer.h>

#import "CGUpnpAvRenderer.h"
#import "CGUpnpAVPositionInfo.h"
#import "CGUpnpAvItem.h"

@interface CGUpnpAvRenderer()
@property (assign) int currentPlayMode;
@end

enum {
	CGUpnpAvRendererPlayModePlay,
	CGUpnpAvRendererPlayModePause,
	CGUpnpAvRendererPlayModeStop,
};

@implementation CGUpnpAvRenderer

@synthesize cAvObject;
@synthesize currentPlayMode;

- (id)init
{
	if ((self = [super init]) == nil)
		return nil;

	cAvObject = cg_upnpav_dmr_new();
	[self setCObject:cg_upnpav_dmr_getdevice(cAvObject)];
	
	[self setCurrentPlayMode:CGUpnpAvRendererPlayModeStop];
	
	return self;
}

- (id) initWithCObject:(CgUpnpDevice *)cobj
{
	if ((self = [super initWithCObject:cobj]) == nil)
		return nil;

	cAvObject = NULL;

	return self;
}

- (CGUpnpAction *)actionOfTransportServiceForName:(NSString *)serviceName
{
	CGUpnpService *avTransService = [self getServiceForType:@"urn:schemas-upnp-org:service:AVTransport:1"];
	if (!avTransService)
		return nil;
	
	return [avTransService getActionForName:serviceName];
}

- (BOOL)setAVTransportAVItem:(CGUpnpAvItem *)avItem
{
	CGUpnpAction *action = [self actionOfTransportServiceForName:@"SetAVTransportURI"];
	if (!action)
		return NO;

    NSMutableString *currentURIMeta = [NSMutableString stringWithString:@"<DIDL-Lite xmlns=\"urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:upnp=\"urn:schemas-upnp-org:metadata-1-0/upnp/\" xmlns:dlna=\"urn:schemas-dlna-org:metadata-1-0/\" xmlns:sec=\"http://www.sec.co.kr/dlna\">"];
    [currentURIMeta appendFormat:@"<item id=\"%@\" parentID=\"%@\" restricted=\"%d\">", [avItem objectId], [[avItem parent] objectId], 0];
    [currentURIMeta appendFormat:@"<dc:title>%@</dc:title>", [avItem title]];
    [currentURIMeta appendFormat:@"<upnp:class>%@</upnp:class>", [avItem upnpClass]];
    [currentURIMeta appendFormat:@"<dc:date>%@</dc:date>", [avItem date]];
    for (CGUpnpAvResource *resource in [avItem resources]) {
        
        [currentURIMeta appendFormat:@"<res protocolInfo=\"%@\"%@ resolution=\"%fx%f\">%@</res>",
         [resource protocolInfo], [resource size] ? [NSString stringWithFormat:@" size=\"%lld\"", [resource size]] : @"", [resource resolution].width, [resource resolution].height, [resource url]];
    }
    [currentURIMeta appendString:@"</item></DIDL-Lite>"];
    
	[action setArgumentValue:@"0" forName:@"InstanceID"];
	[action setArgumentValue:[avItem.resourceUrl absoluteString] forName:@"CurrentURI"];
	[action setArgumentValue:currentURIMeta forName:@"CurrentURIMetaData"];
    
	if (![action post])
		return NO;
	
	return YES;
}

- (BOOL)play;
{
	CGUpnpAction *action = [self actionOfTransportServiceForName:@"Play"];
	if (!action)
		return NO;
	
	[action setArgumentValue:@"0" forName:@"InstanceID"];
	[action setArgumentValue:@"1" forName:@"Speed"];
	
	if (![action post])
		return NO;
	
	[self setCurrentPlayMode:CGUpnpAvRendererPlayModePlay];
	
	return YES;
}

- (BOOL)stop;
{
	CGUpnpAction *action = [self actionOfTransportServiceForName:@"Stop"];
	if (!action)
		return NO;
	
	[action setArgumentValue:@"0" forName:@"InstanceID"];
	
	if (![action post])
		return NO;
	
	[self setCurrentPlayMode:CGUpnpAvRendererPlayModeStop];
	
	return YES;
}

- (BOOL)pause
{
	CGUpnpAction *action = [self actionOfTransportServiceForName:@"Pause"];
	if (!action)
		return NO;
	
	[action setArgumentValue:@"0" forName:@"InstanceID"];
	
	if (![action post])
		return NO;
	
	[self setCurrentPlayMode:CGUpnpAvRendererPlayModePause];
	
	return YES;
}

- (BOOL)next
{
	CGUpnpAction *action = [self actionOfTransportServiceForName:@"Next"];
	if (!action)
		return NO;
	
	[action setArgumentValue:@"0" forName:@"InstanceID"];
	
	if (![action post])
		return NO;
	
	return YES;
}

- (BOOL)previous
{
	CGUpnpAction *action = [self actionOfTransportServiceForName:@"Previous"];
	if (!action)
		return NO;
	
	[action setArgumentValue:@"0" forName:@"InstanceID"];
	
	if (![action post])
		return NO;
	
	return YES;
}
- (BOOL)seek:(float)absTime
{
	CGUpnpAction *action = [self actionOfTransportServiceForName:@"Seek"];
	if (!action)
		return NO;
	
	[action setArgumentValue:@"0" forName:@"InstanceID"];
	[action setArgumentValue:@"ABS_TIME" forName:@"Unit"];
	[action setArgumentValue:[NSString stringWithDurationTime:absTime] forName:@"Target"];
	
	if (![action post])
		return NO;
	
	return YES;
}

- (BOOL)isPlaying
{
	if ([self currentPlayMode] == CGUpnpAvRendererPlayModePlay)
		return YES;
	return NO;
}

- (CGUpnpAVPositionInfo *)positionInfo
{
	CGUpnpAction *action = [self actionOfTransportServiceForName:@"GetPositionInfo"];
	if (!action)
		return NO;
	
	[action setArgumentValue:@"0" forName:@"InstanceID"];
	
	if (![action post])
		return nil;
	
	return [[[CGUpnpAVPositionInfo alloc] initWithAction:action] autorelease];
}

/*
- (BOOL)start
{
	if (!cAvObject)
		return NO;
	return cg_upnpav_dms_start(cAvObject);
}

- (BOOL)stop
{
	if (!cAvObject)
		return NO;
	return cg_upnpav_dms_stop(cAvObject);
}
*/

@end
