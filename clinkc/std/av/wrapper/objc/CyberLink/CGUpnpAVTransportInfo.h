//
//  CGUpnpAVTransportInfo.h
//  clinkc
//
//  Created by 黄江泉 on 14-4-30.
//
//

#import <Foundation/Foundation.h>
#import <CyberLink/UPnP.h>

@class CGUpnpAction;

@interface CGUpnpAVTransportInfo : NSObject {
    
}
@property(retain) CGUpnpAction *upnpAction;
- (id)initWithAction:(CGUpnpAction *)aUpnpAction;
- (NSString *)currentTransportState;
- (NSString *)currentTransportStatus;
- (NSString *)currentSpeed;
@end
