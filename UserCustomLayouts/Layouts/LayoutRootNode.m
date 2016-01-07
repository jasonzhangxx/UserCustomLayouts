//
//  LayoutRootNode.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/19/15.
//
//

#import "LayoutRootNode.h"

@implementation LayoutRootNode

-(instancetype)initWithHandler:(LayoutHandler *)handler view:(NSView *)view
{
    self = [super initWithHandler:handler];
    if (self) {
        _autoRemovedWhenEmpty = NO;
        _view = view;
        _root = self;
        _virtualNode = [[[LayoutNode alloc] initWithHandler:handler] autorelease];
        [super addSubNode:_virtualNode direction:LayoutRelativeDirectionBottom size:NSZeroSize];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onViewDidResize:) name:NSViewFrameDidChangeNotification object:nil];
        
        [self setFrame:NSMakeRect(0, 0, _view.frame.size.width, _view.frame.size.height)];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (id<LayoutDragResponserDelegate>)responser
{
    return self;
}

-(void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    [_virtualNode setFrame:frame];
}

-(void)addSubNode:(LayoutNode*)node direction:(LayoutRelativeDirection)direction relativeNode:(LayoutNode *)relativeNode
{
    //do nothing
}

-(void)removeSubNode:(LayoutNode*)node
{
    //do nothing
}

-(void)replaceNode:(LayoutNode*)node withNode:(LayoutNode*)newNode
{
    if (node == _virtualNode) {
        [super replaceNode:node withNode:newNode];
        _virtualNode = newNode;
    }
}

#pragma mark - view frame observer
- (void)onViewDidResize:(NSNotification*)noti
{
    if(noti.object == _view) {
        [self setFrame:NSMakeRect(0, 0, _view.frame.size.width, _view.frame.size.height)];
    }
}

#pragma mark - Layout Responser
- (void)onLayoutDragIn
{
    
}

- (void)onLayoutDragOut
{
    
}

- (BOOL)onLayoutDragMove:(LayoutDragEvent *)event
{
    return YES;
}

- (BOOL)onLayoutDragEndInside:(LayoutDragEvent *)event
{
    [_handler addLayoutView:event.view toNode:_virtualNode direction:LayoutRelativeDirectionBottom size:NSZeroSize relativeNode:nil];
    return YES;
}

@end
