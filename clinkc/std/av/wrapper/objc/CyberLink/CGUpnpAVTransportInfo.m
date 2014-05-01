//
//  CGUpnpAVTransportInfo.m
//  clinkc
//
//  Created by 黄江泉 on 14-4-30.
//
//

#import "CGUpnpAVTransportInfo.h"

@implementation CGUpnpAVTransportInfo

-(id)initWithAction:(CGUpnpAction *)aUpnpAction
{
	if ((self = [super init])) {
		[self setUpnpAction:aUpnpAction];
	}
	return self;
}

- (void) dealloc
{
	self.upnpAction = nil;
    
	[super dealloc];
}

- (NSString *)currentTransportState
{
    return [[self upnpAction] argumentValueForName:@"CurrentTransportState"];
}

- (NSString *)currentTransportStatus
{
    return [[self upnpAction] argumentValueForName:@"CurrentTransportStatus"];
}

- (NSString *)currentSpeed
{
    return [[self upnpAction] argumentValueForName:@"CurrentSpeed"];
}

@end
