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
//    [[NSColor greenColor] set];
//    NSRectFill(self.bounds);
    
    NSString* str = [NSString stringWithFormat:@"It's %@", _title];
    [str drawAtPoint:NSMakePoint(self.bounds.size.width/2.0, self.bounds.size.height/2.0) withAttributes:nil];
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _hanlder = [[LayoutHandler alloc] initWithView:_window.contentView];
    
    //test
//    LayoutView* view1 = [[[LayoutView alloc] initWithHandler:_hanlder] autorelease];
//    [_hanlder addLayoutView:view1 toNode:_hanlder.rootList[0].virtualNode direction:LayoutRelativeDirectionLeft size:NSZeroSize relativeNode:nil];
//    
//    LayoutView* view2 = [[[LayoutView alloc] initWithHandler:_hanlder] autorelease];
//    [_hanlder addLayoutView:view2 to:view1 direction:LayoutRelativeDirectionLeft size:NSMakeSize(200, 100)];
//    
//    LayoutView* view3 = [[[LayoutView alloc] initWithHandler:_hanlder] autorelease];
//    [_hanlder addLayoutView:view3 to:view1 direction:LayoutRelativeDirectionLeft size:NSMakeSize(200, 100)];
//    
//    LayoutView* view4 = [[[LayoutView alloc] initWithHandler:_hanlder] autorelease];
//    [_hanlder addLayoutView:view4 to:view1 direction:LayoutRelativeDirectionBottom size:NSMakeSize(200, 200)];
//    
//    LayoutView* view5 = [[[LayoutView alloc] initWithHandler:_hanlder] autorelease];
//    [_hanlder addLayoutView:view5 toNode:_hanlder.rootList[0].virtualNode direction:LayoutRelativeDirectionBottom size:NSMakeSize(200, 200) relativeNode:nil];
    
    
    TestView* content1 = [[[TestView alloc] init] autorelease];
    content1.title = @"Content 1";
    TestView* content2 = [[[TestView alloc] init] autorelease];
    content2.title = @"Content 2";
    TestView* content3 = [[[TestView alloc] init] autorelease];
    content3.title = @"Content 3";
    TabLayoutView *tabView1 = [[[TabLayoutView alloc] initWithHandler:_hanlder view:content1] autorelease];
    [tabView1 insertContentView:content2 index:0 highlighted:YES];
    [tabView1 insertContentView:content3 index:0 highlighted:YES];
    [_hanlder addLayoutView:tabView1 toNode:_hanlder.rootList[0].virtualNode direction:LayoutRelativeDirectionLeft size:NSZeroSize relativeNode:nil];
    

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
