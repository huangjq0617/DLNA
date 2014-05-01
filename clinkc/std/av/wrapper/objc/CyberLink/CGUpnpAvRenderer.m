//
//  CGUpnpAvServer.m
//  CyberLink for C
//
//  Created by Satoshi Konno on 08/07/02.
//  Copyright 2008 Satoshi Konno. All rights reserved.
//

#include <cybergarage/upnp/std/av/cmediarenderer.h>
#include <cybergarage/upnp/std/av/cdidl.h>

#import "CGUpnpAvRenderer.h"
#import "CGUpnpAVPositionInfo.h"
#import "CGUpnpAVTransportInfo.h"
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
    
    CgXmlNode *item = cg_xml_node_new();
    cg_xml_node_copy(item, avItem.cXmlNode);
    
    CgXmlNode *didl_node = cg_upnpav_didl_node_new();
    cg_xml_node_addchildnode(didl_node, item);
    
    CgString *currentUriMeta = cg_string_new();
    NSMutableString *urlMetaValue = [NSMutableString stringWithUTF8String:cg_xml_node_tostring(didl_node, YES, currentUriMeta)];
    [urlMetaValue insertString:@CG_UPNP_XML_DECLARATION atIndex:0];
    
	[action setArgumentValue:@"0" forName:@"InstanceID"];
	[action setArgumentValue:[avItem.resourceUrl absoluteString] forName:@"CurrentURI"];
	[action setArgumentValue:urlMetaValue forName:@"CurrentURIMetaData"];
    
//    cg_xml_node_print(didl_node);
    
    cg_string_delete(currentUriMeta);
    cg_xml_node_delete(didl_node);
    
	if (![action post])
		return NO;
	
	return YES;
}

- (BOOL)play
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

- (BOOL)stop
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
	[action setArgumentValue:@"REL_TIME" forName:@"Unit"];
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

- (CGUpnpAVTransportInfo *)transportInfo
{
    CGUpnpAction *action = [self actionOfTransportServiceForName:@"GetTransportInfo"];
	if (!action)
		return NO;
	
	[action setArgumentValue:@"0" forName:@"InstanceID"];
	
	if (![action post])
		return nil;
	
	return [[[CGUpnpAVTransportInfo alloc] initWithAction:action] autorelease];
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
