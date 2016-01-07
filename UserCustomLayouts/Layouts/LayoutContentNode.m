//
//  LayoutContentNode.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/19/15.
//
//

#import "LayoutContentNode.h"
#import "LayoutView.h"

@implementation LayoutContentNode

-(instancetype)initWithHandler:(LayoutHandler *)handler view:(LayoutView*)view
{
    self = [super initWithHandler:handler];
    if (self) {
        _view = [view retain];
        _align = LayoutAlignmentLeafOnly;
    }
    return self;
}

- (void)dealloc
{
    [_view release];
    [super dealloc];
}

- (NSSize)minSize
{
    if (_view) {
        NSSize size = _view.layoutMinSize;
        if(size.width<LayoutMinSize.width) size.width=LayoutMinSize.width;
        if(size.height<LayoutMinSize.height) size.height=LayoutMinSize.height;
        return size;
    }
    return [super minSize];
}

- (id<LayoutDragResponserDelegate>)responser
{
    return _view;
}

- (void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    _view.frame = frame;
}

- (void)addSubNode:(LayoutNode *)node direction:(LayoutRelativeDirection)direction relativeNode:(LayoutNode *)relativeNode
{
    //do nothing
}

- (void)removeSubNode:(LayoutNode *)node
{
    //do nothing
}

-(void)replaceNode:(LayoutNode*)node withNode:(LayoutNode*)newNode
{
    //do nothing
}

- (void)relayout
{
    //do nothing
}

@end
