//
//  AppDelegate.m
//  UserCustomLayouts
//
//  Created by Jason.Zhang on 1/7/16.
//  Copyright © 2016 Jason.Zhang. All rights reserved.
//

#import "AppDelegate.h"


#import "LayoutView.h"
#import "LayoutRootNode.h"
#import "TabLayoutView.h"

@interface AppDelegate ()

@property (assign) IBOutlet NSWindow *window;
@end

@interface TestView : NSView <TabLayoutContentInterface>
@property(nonatomic, retain) NSString* title;
@end

@implementation TestView

- (NSSize)layoutMinSize
{
    return NSZeroSize;
}

- (NSString*)layoutTitle
{
    return _title;
}

//debug
- (void)drawRect:(NSRect)aRect
{
    [[NSColor whiteColor] set];
    NSRectFill(self.bounds);
    
    NSString* str = [NSString stringWithFormat:@"It's %@", _title];
    [str drawAtPoint:NSMakePoint(self.bounds.size.width/2.0, self.bounds.size.height/2.0) withAttributes:nil];
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [_window setBackgroundColor:[NSColor colorWithRed:.6353 green:.6353 blue:.6353 alpha:1]];
    _hanlder = [[LayoutHandler alloc] initWithView:_window.contentView];
    
    //test
    TestView* content1 = [[[TestView alloc] init] autorelease];
    content1.title = @"Content 1";
    TestView* content2 = [[[TestView alloc] init] autorelease];
    content2.title = @"Content 2";
    TestView* content3 = [[[TestView alloc] init] autorelease];
    content3.title = @"Content 3";
    TestView* content4 = [[[TestView alloc] init] autorelease];
    content4.title = @"Content 4";
    TestView* content5 = [[[TestView alloc] init] autorelease];
    content5.title = @"Content 5";
    TestView* content6 = [[[TestView alloc] init] autorelease];
    content6.title = @"Content 6";
    TestView* content7 = [[[TestView alloc] init] autorelease];
    content7.title = @"Content 7";
    TabLayoutView *tabView1 = [[[TabLayoutView alloc] initWithHandler:_hanlder view:content1] autorelease];
    [tabView1 insertContentView:content2 index:0 highlighted:YES];
    [tabView1 insertContentView:content3 index:0 highlighted:YES];
    [tabView1 insertContentView:content4 index:0 highlighted:YES];
    [tabView1 insertContentView:content5 index:0 highlighted:YES];
    [tabView1 insertContentView:content6 index:0 highlighted:YES];
    [tabView1 insertContentView:content7 index:0 highlighted:YES];
    [_hanlder addLayoutView:tabView1 toNode:_hanlder.firstResponsedRoot direction:LayoutRelativeDirectionLeft size:NSZeroSize relativeNode:nil];
    

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
