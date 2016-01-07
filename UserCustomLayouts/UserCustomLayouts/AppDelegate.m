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

@interface AppDelegate ()

@property (assign) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _hanlder = [[LayoutHandler alloc] initWithView:_window.contentView];
    
    //test
    LayoutView* view1 = [[[LayoutView alloc] initWithHandler:_hanlder] autorelease];
    [_hanlder addLayoutView:view1 toNode:_hanlder.rootList[0].virtualNode direction:LayoutRelativeDirectionLeft size:NSZeroSize relativeNode:nil];
    
    LayoutView* view2 = [[[LayoutView alloc] initWithHandler:_hanlder] autorelease];
    [_hanlder addLayoutView:view2 to:view1 direction:LayoutRelativeDirectionLeft size:NSMakeSize(200, 100)];
    
    LayoutView* view3 = [[[LayoutView alloc] initWithHandler:_hanlder] autorelease];
    [_hanlder addLayoutView:view3 to:view1 direction:LayoutRelativeDirectionLeft size:NSMakeSize(200, 100)];
    
    LayoutView* view4 = [[[LayoutView alloc] initWithHandler:_hanlder] autorelease];
    [_hanlder addLayoutView:view4 to:view1 direction:LayoutRelativeDirectionBottom size:NSMakeSize(200, 200)];
    
    LayoutView* view5 = [[[LayoutView alloc] initWithHandler:_hanlder] autorelease];
    [_hanlder addLayoutView:view5 toNode:_hanlder.rootList[0].virtualNode direction:LayoutRelativeDirectionBottom size:NSMakeSize(200, 200) relativeNode:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
