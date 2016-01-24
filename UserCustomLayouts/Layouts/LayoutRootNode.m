//
//  LayoutRootNode.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/19/15.
//
//

#import "LayoutRootNode.h"
#import "LayoutView.h"
#import "RootLayoutView.h"

@implementation LayoutRootNode

-(instancetype)initWithHandler:(LayoutHandler *)handler view:(NSView *)view
{
    self = [super initWithHandler:handler];
    if (self) {
        _autoRemovedWhenEmpty = NO;
        _containerView = [view retain];
        _root = self;
        _virtualNode = [[[LayoutNode alloc] initWithHandler:handler] autorelease];
        [super addSubNode:_virtualNode direction:LayoutRelativeDirectionBottom size:NSZeroSize relativeNode:nil];
        _rootView = [[[RootLayoutView alloc] initWithHandler:_handler] autorelease];
        _rootView.rootNode = self;
        [_containerView addSubview:_rootView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onViewDidResize:) name:NSViewFrameDidChangeNotification object:nil];
        
        [self setFrame:NSMakeRect(0, 0, _containerView.frame.size.width, _containerView.frame.size.height)];
    }
    return self;
}

- (void)dealloc
{
    [_containerView release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id<LayoutDragResponserDelegate>)responser
{
    return _rootView;
}

- (NSWindow*)containerWindow
{
    return _containerView.window;
}

-(void)setFrame:(NSRect)frame
{
    [_rootView setFrame:frame];
    [super setFrame:frame];
    [self resetResizeRects];
}

-(void)addSubNode:(LayoutNode *)node direction:(LayoutRelativeDirection)direction size:(NSSize)size relativeNode:(LayoutNode *)relativeNode
{
    [_virtualNode addSubNode:node direction:direction size:size relativeNode:relativeNode];
}

-(void)removeSubNode:(LayoutNode*)node
{
    [_virtualNode removeSubNode:node];
}

-(void)replaceNode:(LayoutNode*)node withNode:(LayoutNode*)newNode
{
    if (node == _virtualNode) {
        [super replaceNode:node withNode:newNode];
        _virtualNode = newNode;
    }
}

- (void)resetResizeRects
{
    [_rootView resetResizeRects];
}

#pragma mark - view frame observer
- (void)onViewDidResize:(NSNotification*)noti
{
    if(noti.object == _containerView) {
        [self setFrame:NSMakeRect(0, 0, _containerView.frame.size.width, _containerView.frame.size.height)];
    }
}

@end
