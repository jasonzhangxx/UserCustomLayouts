//
//  RootLayoutView.m
//  UserCustomLayouts
//
//  Created by Yanjie Zhang on 16/1/21.
//  Copyright © 2016年 Jason.Zhang. All rights reserved.
//

#import "RootLayoutView.h"
#import "LayoutRootNode.h"

@implementation RootLayoutResizeRect

+ (instancetype)resizeRectWithRect:(NSRect)rect align:(LayoutAlignment)align prevNode:(LayoutNode *)prevNode nextNode:(LayoutNode *)nextNode
{
    RootLayoutResizeRect *resizeRect = [[[RootLayoutResizeRect alloc] init] autorelease];
    resizeRect.rect = rect;
    resizeRect.align = align;
    resizeRect.prevNode = prevNode;
    resizeRect.nextNode = nextNode;
    return resizeRect;
}

@end

@implementation RootLayoutView

- (instancetype)initWithHandler:(LayoutHandler *)handler
{
    self = [super initWithHandler:handler];
    if (self) {
        _resizeRects = [[NSMutableArray alloc] init];
        _resizing = NO;
    }
    return self;
}

- (void)dealloc
{
    [_resizeRects release];
    [super dealloc];
}

#pragma mark - resize event
- (void)resetResizeRects
{
    [_resizeRects removeAllObjects];
    [self calculateResizeRect:_resizeRects layoutNode:_rootNode.virtualNode];
    [self.window invalidateCursorRectsForView:self];
}

- (void)calculateResizeRect:(NSMutableArray<RootLayoutResizeRect*>*)rectsArray layoutNode:(LayoutNode*)node
{
    if (node.subNodes.count > 1) {
        LayoutNode *curNode=nil, *lastNode=nil;
        for (int i=0; i<node.subNodes.count; i++) {
            lastNode = curNode;
            curNode = node.subNodes[i];
            if (lastNode != nil) {
                if (node.align == LayoutAlignmentVertical) {//Vertical
                    NSRect rect;
                    rect.origin.x = lastNode.frame.origin.x;
                    rect.size.width = lastNode.frame.size.width;
                    rect.origin.y = lastNode.frame.origin.y+lastNode.frame.size.height;
                    rect.size.height = curNode.frame.origin.y - rect.origin.y;
                    [rectsArray addObject:[RootLayoutResizeRect resizeRectWithRect:rect align:LayoutAlignmentVertical prevNode:lastNode nextNode:curNode]];
                }
                else {//Horizontal
                    NSRect rect;
                    rect.origin.x = lastNode.frame.origin.x+lastNode.frame.size.width;
                    rect.size.width = curNode.frame.origin.x - rect.origin.x;
                    rect.origin.y = lastNode.frame.origin.y;
                    rect.size.height = lastNode.frame.size.height;
                    [rectsArray addObject:[RootLayoutResizeRect resizeRectWithRect:rect align:LayoutAlignmentHorizontal prevNode:lastNode nextNode:curNode]];
                }
            }
        }
    }
    if(node.subNodes.count > 0) {
        [node.subNodes enumerateObjectsUsingBlock:^(LayoutNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self calculateResizeRect:rectsArray layoutNode:obj];
        }];
    }
}

- (void)resetCursorRects
{
    [_resizeRects enumerateObjectsUsingBlock:^(RootLayoutResizeRect * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addCursorRect:obj.rect cursor:obj.align==LayoutAlignmentVertical?[NSCursor resizeUpDownCursor]:[NSCursor resizeLeftRightCursor]];
    }];
}

#pragma mark - mouse event
- (void)mouseDown:(NSEvent *)theEvent
{
    _resizing = NO;
    NSPoint location = [self convertPoint:theEvent.locationInWindow fromView:nil];
    [_resizeRects enumerateObjectsUsingBlock:^(RootLayoutResizeRect * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (location.x>=floor(obj.rect.origin.x) &&
            location.y>=floor(obj.rect.origin.y) &&
            location.x<=ceil(obj.rect.origin.x+obj.rect.size.width) &&
            location.y<=ceil(obj.rect.origin.y+obj.rect.size.height)) {//NSPointInRect is not good here
            _resizing = YES;
            _mouseDownRect = [obj retain];
            _mouseDownRelativeLocation = NSMakePoint(location.x-(_mouseDownRect.prevNode.frame.origin.x+_mouseDownRect.prevNode.frame.size.width), location.y-(_mouseDownRect.prevNode.frame.origin.y+_mouseDownRect.prevNode.frame.size.height));
            *stop = YES;
        }
    }];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (_resizing == YES) {
        NSPoint location = [self convertPoint:theEvent.locationInWindow fromView:nil];
        if (_mouseDownRect.align == LayoutAlignmentVertical) {
            NSPoint releativeLocation = NSMakePoint(location.x-(_mouseDownRect.prevNode.frame.origin.x+_mouseDownRect.prevNode.frame.size.width), location.y-(_mouseDownRect.prevNode.frame.origin.y+_mouseDownRect.prevNode.frame.size.height));
            CGFloat variation = releativeLocation.y-_mouseDownRelativeLocation.y;
            [_mouseDownRect.nextNode.parentNode resizeSubNode:_mouseDownRect.prevNode variation:variation direction:LayoutRelativeDirectionTop];
        }
        else {
            NSPoint releativeLocation = NSMakePoint(location.x-(_mouseDownRect.prevNode.frame.origin.x+_mouseDownRect.prevNode.frame.size.width), location.y-(_mouseDownRect.prevNode.frame.origin.y+_mouseDownRect.prevNode.frame.size.height));
            CGFloat variation = releativeLocation.x-_mouseDownRelativeLocation.x;
            [_mouseDownRect.nextNode.parentNode resizeSubNode:_mouseDownRect.prevNode variation:variation direction:LayoutRelativeDirectionRight];
        }
        [self resetResizeRects];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    _resizing = NO;
    [_mouseDownRect release];
    _mouseDownRect = nil;
}

- (BOOL)isResizeAvailable:(LayoutRelativeDirection)dir
{
    switch (dir) {
        case LayoutRelativeDirectionLeft: {
            return _frame.origin.x>=0.01;
        }
        case LayoutRelativeDirectionRight: {
            return self.superview.bounds.size.width-(_frame.origin.x+_frame.size.width)>=0.01;
        }
        case LayoutRelativeDirectionBottom: {
            return _frame.origin.y>=0.01;
        }
        case LayoutRelativeDirectionTop: {
            return self.superview.bounds.size.height-(_frame.origin.y+_frame.size.height)>=0.01;
        }
        default:
            break;
    }
    return NO;
}

#pragma mark - sender delegate
- (LayoutView*)layoutWillMove
{
    //It's impossible.
    return nil;
}

#pragma mark - Layout Responser, default handler
static CGFloat outspreadWidth = 24;
- (void)onLayoutDragIn
{
    
}

- (void)onLayoutDragOut
{
    
}

- (BOOL)onLayoutDragMove:(LayoutDragEvent *)event
{
    if (_rootNode.virtualNode.subNodes.count == 0) {
        NSPoint locationInView = [self convertPoint:event.location fromView:self.superview];
        if (NSPointInRect(locationInView, self.bounds) == YES) {
            [event.panel placeToView:self frame:self.bounds contentView:[event.sender getPlacedDisplayView]];
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        LayoutRelativeDirection direction = [self checkLayoutPlacedDirection:event.location outspread:outspreadWidth];
        if (direction != LayoutRelativeDirectionNone) {
            [event.panel placeToView:self frame:[self getPlacedFrame:direction] contentView:[event.sender getPlacedDisplayView]];
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (BOOL)onLayoutDragEndInside:(LayoutDragEvent *)event
{
    if (_rootNode.virtualNode.subNodes.count == 0) {
        NSPoint locationInView = [self convertPoint:event.location fromView:self.superview];
        if (NSPointInRect(locationInView, self.bounds) == YES) {
            LayoutView* view = [event.sender layoutWillMove];
            if (view != nil) {
                [_handler addLayoutView:view toNode:_rootNode.virtualNode direction:LayoutRelativeDirectionBottom size:NSZeroSize relativeNode:nil];
            }
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        LayoutRelativeDirection direction = [self checkLayoutPlacedDirection:event.location outspread:outspreadWidth];
        if (direction != LayoutRelativeDirectionNone) {
            LayoutView* view = [event.sender layoutWillMove];
            if (view != nil) {
                [_handler addLayoutView:view toNode:_rootNode.virtualNode direction:direction size:[self getPlacedFrame:direction].size  relativeNode:nil];
            }
            return YES;
        }
        else {
            return NO;
        }
    }
}

@end
