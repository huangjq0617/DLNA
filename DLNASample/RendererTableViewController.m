 //
//  RendererTableViewController.m
//  DLNASample
//
//  Created by 健司 古山 on 12/07/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RendererTableViewController.h"
#import "AppDelegate.h"
#include <cybergarage/xml/cxml.h>
#include <cybergarage/upnp/std/av/cupnpav.h>
#import <CyberLink/UPnPAV.h>
#import "UPnPDeviceTableViewCell.h"

@interface RendererTableViewController ()

@end

@implementation RendererTableViewController
@synthesize dataSource = _dataSource;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithAvController:(CGUpnpAvController*)aController
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.dataSource = [aController renderers];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 0
#else
    static NSString *CELLID = @"upnprootobj";
	
	UPnPDeviceTableViewCell *cell = (UPnPDeviceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELLID];
	if (cell == nil) {
		cell = [[[UPnPDeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELLID] autorelease];
	}
	
	int row = (int)[indexPath indexAtPosition:1];
	if (row < [self.dataSource count]) {
		CGUpnpDevice *device = [self.dataSource objectAtIndex:row];
		[cell setDevice:device];
	}
    
	return cell;
#endif
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    appDelagete.avRenderer = (CGUpnpAvRenderer*)[self.dataSource objectAtIndex:indexPath.row];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    {
        CgXmlNode *item = cg_xml_node_new();
        cg_xml_node_setname(item, "item");
        cg_xml_node_setattribute(item, CG_UPNPAV_OBJECT_ID, "0" );
        cg_xml_node_setattribute(item, CG_UPNPAV_OBJECT_PARENTID, "0" );
        cg_xml_node_setattribute(item, CG_UPNPAV_OBJECT_RESTRICTED, "1" );
        
        CgXmlNode *title = cg_xml_node_new();
        cg_xml_node_setname(title, CG_UPNPAV_OBJECT_TITLE);
        cg_xml_node_setvalue(title, "");
        
        cg_xml_node_addchildnode(item, title);
        
        CgXmlNode *upnpClass = cg_xml_node_new();
        cg_xml_node_setname(upnpClass, CG_UPNPAV_OBJECT_UPNPCLASS);
        cg_xml_node_setvalue(upnpClass, (char *)[@"object.item.videoItem" UTF8String]);
        
        cg_xml_node_addchildnode(item, upnpClass);
        
        CgXmlNode *res = cg_xml_node_new();
        cg_xml_node_setname(res, "res");
        cg_xml_node_setattribute(res, "protocolInfo", "http-get:*:video/mp4:*" );
        cg_xml_node_setvalue(res, ((char *)[@"http://123.125.86.30/vkp.tc.qq.com/w0014m0qccd.mp4?vkey=CD8B6486754FE9FF7B05AED4E71473A43190BE08CFFB81E5B1BD464EBF1FA118D62EE3A334F53FD4CBA8D41D18138704B4A11CD0166BFF95&br=62589&platform=0&fmt=mp4&level=0&type=mp4" UTF8String]) );
        
        cg_xml_node_addchildnode(item, res);
        
        CGUpnpAvItem *avItem = [[CGUpnpAvItem alloc] initWithXMLNode:item];
        [avItem addResource:[[CGUpnpAvResource alloc] initWithXMLNode:res]];
        
        cg_xml_node_delete(item);
        
        BOOL success = NO;
        if ([appDelagete.avRenderer setAVTransportAVItem:avItem]) {
            success = [appDelagete.avRenderer play];
        }
    }
}

@end
