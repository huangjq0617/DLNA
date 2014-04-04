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
#import "CGUpnpAvItem.h"

#define ADD_CHILDNODE_TO_NODE(node, name, value) \
{ \
    if (value) \
    { \
        CgXmlNode *newNode = cg_xml_node_new(); \
        cg_xml_node_setname(newNode, (name)); \
        cg_xml_node_setvalue(newNode, (char *)[value UTF8String]); \
        cg_xml_node_addchildnode(node, newNode); \
    } \
}

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
    
    CgXmlNode *didl_node = cg_upnpav_didl_node_new();
    CgString *currentUriMeta = cg_string_new();
    
    CgXmlNode *item = cg_xml_node_new();
    cg_xml_node_setname(item, "item");
    cg_xml_node_setattribute(item, CG_UPNPAV_OBJECT_ID, ((char *)[[NSString stringWithFormat:@"%@", [avItem objectId]] UTF8String]) );
    cg_xml_node_setattribute(item, CG_UPNPAV_OBJECT_PARENTID, ((char *)[[NSString stringWithFormat:@"%@", [[avItem parent] objectId]] UTF8String]) );
    cg_xml_node_setattribute(item, CG_UPNPAV_OBJECT_RESTRICTED, ((char *)[[NSString stringWithFormat:@"%d", 1] UTF8String]) );
    
    cg_xml_node_addchildnode(didl_node, item);
    
    ADD_CHILDNODE_TO_NODE(item, CG_UPNPAV_OBJECT_TITLE, [avItem title]);
    ADD_CHILDNODE_TO_NODE(item, CG_UPNPAV_OBJECT_UPNPCLASS, [avItem upnpClass]);
    
    for (CGUpnpAvResource *resource in [avItem resources]) {
        
        CgXmlNode *res = cg_xml_node_new();
        cg_xml_node_setname(res, "res");
        cg_xml_node_setattribute(res, "protocolInfo", ((char *)[[NSString stringWithFormat:@"%@", [resource protocolInfo]] UTF8String]) );
        if ([resource size]) {
            cg_xml_node_setattribute(res, "size", ((char *)[[NSString stringWithFormat:@"%lld", [resource size]] UTF8String]) );
        }
        cg_xml_node_setattribute(res, "resolution", ((char *)[[NSString stringWithFormat:@"%dx%d",
                                                               (int)[resource resolution].width, (int)[resource resolution].height] UTF8String]) );
        cg_xml_node_setvalue(res, ((char *)[[resource url] UTF8String]) );
        cg_xml_node_addchildnode(item, res);
    }
    
    ADD_CHILDNODE_TO_NODE(item, CG_UPNPAV_OBJECT_ALBUM, [avItem album]);
    ADD_CHILDNODE_TO_NODE(item, CG_UPNPAV_OBJECT_ALBUMARTURI, [avItem albumArtURI]);
    ADD_CHILDNODE_TO_NODE(item, CG_UPNPAV_OBJECT_ARTIST, [avItem artist]);
    ADD_CHILDNODE_TO_NODE(item, CG_UPNPAV_OBJECT_DATE, [avItem date]);
    
	[action setArgumentValue:@"0" forName:@"InstanceID"];
	[action setArgumentValue:[avItem.resourceUrl absoluteString] forName:@"CurrentURI"];
    
    NSMutableString *urlMetaValue = [NSMutableString stringWithUTF8String:cg_xml_node_tostring(didl_node, YES, currentUriMeta)];
    [urlMetaValue insertString:@CG_UPNP_XML_DECLARATION atIndex:0];
    
	[action setArgumentValue:urlMetaValue forName:@"CurrentURIMetaData"];
    
    cg_string_delete(currentUriMeta);
    cg_xml_node_delete(didl_node);
    
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
