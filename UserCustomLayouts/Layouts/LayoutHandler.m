//
//  LayoutHandler.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/15/15.
//
//

#import "LayoutHandler.h"
#import "LayoutView.h"
#import "LayoutNode.h"
#import "LayoutRootNode.h"
#import "LayoutContentNode.h"

@implementation LayoutDragEvent

+ (LayoutDragEvent*)eventWithSender:(LayoutView*)sender location:(NSPoint)location panel:(LayoutDraggingPanel *)panel
{
    LayoutDragEvent* event = [[[LayoutDragEvent alloc] init] autorelease];
    event.sender = sender;
    event.location = location;
    event.panel = panel;
    return event;
}

- (void)dealloc
{
    [super dealloc];
}

@end

@implementation LayoutHandler

-(NSString*)description
{
    NSMutableString* des = [NSMutableString stringWithString:@"["];
    [_rootList enumerateObjectsUsingBlock:^(LayoutRootNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [des appendFormat:(idx==0?@"%@":@",%@"),obj.description];
    }];
    [des appendString:@"]"];
    return des;
}

- (id)initWithView:(NSView *)view
{
    self = [super init];
    if (self) {
        _rootList = [[NSMutableArray alloc] init];
        _viewMap = [[NSMutableDictionary alloc] init];
        LayoutRootNode* node = [[[LayoutRootNode alloc] initWithHandler:self view:view] autorelease];
        [_rootList addObject:node];
        
        _dragState = LayoutDragStateUnkown;
        _draggingPanel = [[LayoutDraggingPanel alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0) styleMask:(NSBorderlessWindowMask) backing:NSBackingStoreBuffered defer:YES];
        _draggingPanel.delegate = self;
        _draggingPanel.floatingPanel = YES;
    }
    return self;
}

- (void)dealloc
{
    [_rootList release];
    [_viewMap release];
    [_draggingPanel release];
    [super dealloc];
}

- (NSArray*)rootList
{
    return (NSArray*)_rootList;
}

- (LayoutRootNode*)firstResponsedRoot
{
    return _rootList[0];
}

- (BOOL)changeFirstResponsedRootIfNeeded:(NSPoint)locatioInScreen
{
    for (int i=0; i<_rootList.count; i++) {
        if (NSPointInRect(locatioInScreen, _rootList[i].view.window.frame)) {
            if (i > 0) {
                LayoutRootNode* root = [_rootList[i] retain];
                [_rootList removeObjectAtIndex:i];
                [_rootList insertObject:root atIndex:0];
                [root release];
                [root.view.window makeKeyAndOrderFront:nil];
//                NSLog(@"root change");
                return YES;
            }
            else {
                return NO;
            }
        }
    }
    return NO;
}

- (void)handleMouseEvent:(LayoutView*)sender type:(LayoutDragState)type location:(NSPoint)locationInWindow
{
    switch (type) {
        case LayoutDragStateBegin:
        {
            if (_dragState != LayoutDragStateUnkown) {
                [self cancelDragging];
            }
            [self startDragging:sender];
            break;
        }
        case LayoutDragStateDraging:
        {
            if(_dragState == LayoutDragStateBegin || _dragState == LayoutDragStateDraging) {
                [self continueDragging:locationInWindow];
            }
            break;
        }
        case LayoutDragStateEnd:
        {
            if (_dragState == LayoutDragStateDraging) {
                [self finishDragging:locationInWindow];
            }
            break;
        }
        default:
            break;
    }
}

- (void)handleResizeEvent:(LayoutView *)view variation:(float)variation direction:(LayoutRelativeDirection)dir
{
    LayoutNode* targetNode = [self findAssociatedNode:view];
    if (targetNode == nil) {
        //TODO targetView isn't in the tree
        return;
    }
    LayoutNode* resizeNode = nil;
    while (targetNode != nil && targetNode.parentNode != targetNode.root) {
        if ((targetNode.parentNode.align & dir) > 0) {
            //filter node's edge
            unsigned long idx = [targetNode.parentNode.subNodes indexOfObject:targetNode];
            if ((dir & 0b0100) > 0) {
                if (idx < targetNode.parentNode.subNodes.count-1) {//not the last
                    resizeNode = targetNode;
                    break;
                }
            }
            else {
                if (idx > 0) {//not the first
                    resizeNode = targetNode;
                    break;
                }
            }
        }
        targetNode = targetNode.parentNode;
    }
    if (resizeNode != nil) {
        [resizeNode.parentNode resizeSubNode:resizeNode variation:variation direction:dir];
    }
    else {
        //TODO cannot find node to resize
        NSLog(@"cannot find node to resize");
    }
}

- (void)addLayoutView:(LayoutView *)layoutView to:(LayoutView *)targetView direction:(LayoutRelativeDirection)dir size:(NSSize)size
{
    if ([self findAssociatedNode:layoutView] != nil) {
        //TODO already in the tree
        return;
    }
    
    LayoutNode* targetNode = [self findAssociatedNode:targetView];
    if (targetNode == nil) {
        //TODO targetView isn't in the tree
        return;
    }
    
    if ((targetNode.parentNode.align & dir) > 0) {
        [self addLayoutView:layoutView toNode:targetNode.parentNode direction:dir size:size relativeNode:targetNode];
    }
    else {
        [self addLayoutView:layoutView toNode:targetNode direction:dir size:size relativeNode:nil];
    }
}

- (void)addLayoutView:(LayoutView *)layoutView toNode:(LayoutNode *)targetNode direction:(LayoutRelativeDirection)dir size:(NSSize)size relativeNode:(LayoutNode *)relativeNode
{
    if ([self findAssociatedNode:layoutView] != nil) {
        //TODO already in the tree
        return;
    }
    
    if (layoutView.superview != targetNode.root.view) {
        [layoutView removeFromSuperview];
        [targetNode.root.view addSubview:layoutView];
    }
    
    LayoutContentNode* subNode = [[[LayoutContentNode alloc] initWithHandler:self view:layoutView] autorelease];
    [_viewMap setObject:subNode forKey:[NSNumber numberWithUnsignedLong:layoutView.identifier]];//add relationship to viewmap
    
    if ((targetNode.align & dir) > 0) {
        [targetNode addSubNode:subNode direction:dir size:size relativeNode:relativeNode];
    }
    else {//shift down leaf node
        [targetNode retain];
        LayoutNode* combineNode = [[[LayoutNode alloc] initWithHandler:self] autorelease];
        [targetNode.parentNode replaceNode:targetNode withNode:combineNode];
        [combineNode addSubNode:targetNode direction:dir size:combineNode.frame.size];

        [combineNode addSubNode:subNode direction:dir size:size relativeNode:relativeNode];
        [targetNode release];
    }
}

- (void)removeLayoutView:(LayoutView *)layoutView
{
    LayoutNode* node = [self findAssociatedNode:layoutView];
    if (!node) {
        //TODO node is not exist
        return;
    }
    
    [layoutView removeFromSuperview];
    
    LayoutNode* parentNode = node.parentNode;
    [_viewMap removeObjectForKey:[NSNumber numberWithUnsignedLong:layoutView.identifier]];//remove relationship from viewmap
    [node removeFromParent];//rootNode's virtualNode do nothing
    
    if (parentNode.parentNode == parentNode.root) {//root's virtualNode
        if (parentNode.root.autoRemovedWhenEmpty == YES && parentNode.subNodes.count == 0) {
            [parentNode.root.view.window close];
        }
    }
    //subNodes.count would not be 0 expect virtualNode, just check 1
    else if(parentNode.subNodes.count == 1) {
        [parentNode retain];
        [parentNode.parentNode replaceNode:parentNode withNode:parentNode.subNodes[0]];
        [parentNode release];
    }
}

- (void)createNewLayoutWindow:(LayoutView *)layoutView location:(NSPoint)locationInScreen
{
    if (layoutView == nil) {
        //TODO
        return;
    }
    NSWindow* newWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, layoutView.bounds.size.width, layoutView.bounds.size.height) styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask) backing:NSBackingStoreBuffered defer:YES];
    [newWindow setFrame:NSMakeRect(locationInScreen.x-newWindow.frame.size.width/2.0, locationInScreen.y-newWindow.frame.size.height/2.0, newWindow.frame.size.width, newWindow.frame.size.height) display:YES];
    newWindow.delegate = self;
    newWindow.hasShadow = YES;
    
    LayoutRootNode* root = [[[LayoutRootNode alloc] initWithHandler:self view:newWindow.contentView] autorelease];
    root.autoRemovedWhenEmpty = YES;
    [_rootList insertObject:root atIndex:0];
    [self addLayoutView:layoutView toNode:root.virtualNode direction:LayoutRelativeDirectionBottom size:NSZeroSize relativeNode:nil];
    [newWindow makeKeyAndOrderFront:nil];
}

#pragma mark - dragging handle
- (void)startDragging:(LayoutView*)sender
{
    _dragSender = sender;
    _focusedNode = nil;
    _dragState = LayoutDragStateBegin;
    
    if (_dragSender != nil) {
        if ([_dragSender respondsToSelector:@selector(layoutDragDidBegin)]) {
           [_dragSender layoutDragDidBegin];
        }
    }
}

- (void)continueDragging:(NSPoint)locationInWindow
{
    _dragState = LayoutDragStateDraging;
    
    NSPoint locationInScreen = NSPointFromWindowToScreen(_dragSender.window, locationInWindow);
    [self changeFirstResponsedRootIfNeeded:locationInScreen];
    NSPoint locationInResponsedRootWindow = NSPointFromScreenToWindow(self.firstResponsedRoot.view.window, locationInScreen);
    
    LayoutNode* targetNode = [self findeFirstResponsedNode:locationInResponsedRootWindow];//return targetNode or rootNode
    if (_focusedNode != targetNode) {
        [_focusedNode.responser onLayoutDragOut];
        _focusedNode = targetNode;
        if (_focusedNode != nil) {
            [_focusedNode.responser onLayoutDragIn];
        }
    }
    
    BOOL processed = NO;
    if (_focusedNode != nil) {
        NSPoint convertedLocation = [self.firstResponsedRoot.view convertPoint:locationInResponsedRootWindow fromView:nil];
        LayoutDragEvent* event = [LayoutDragEvent eventWithSender:_dragSender location:convertedLocation panel:_draggingPanel];
        processed = [_focusedNode.responser onLayoutDragMove:event];
    }
    
    if (_draggingPanel.isVisible == NO) {
        [_draggingPanel snapshotView:_dragSender];
        [_draggingPanel restoreToOrigin:NO];
    }
    
    if (processed == NO) {
        //move draggingPanel
        [_draggingPanel restoreToOrigin:YES];
        [_draggingPanel moveToLocation:locationInScreen animated:NO];
    }
    
    // prevent flash from error position
    if (_draggingPanel.isVisible == NO) {
        [_draggingPanel makeKeyAndOrderFront:nil];
    }
    
    if (_dragSender != nil) {
        if ([_dragSender respondsToSelector:@selector(layoutDragDidDragging)]) {
            [_dragSender layoutDragDidDragging];
        }
    }
}

- (void)finishDragging:(NSPoint)locationInWindow
{
    _dragState = LayoutDragStateEnd;
    
    NSPoint locationInScreen = NSPointFromWindowToScreen(_dragSender.window, locationInWindow);
    [self changeFirstResponsedRootIfNeeded:locationInScreen];
    NSPoint locationInResponsedRootWindow = NSPointFromScreenToWindow(self.firstResponsedRoot.view.window, locationInScreen);
    
    BOOL processed = NO;
    if (_focusedNode != nil) {
        NSPoint convertedLocation = [self.firstResponsedRoot.view convertPoint:locationInResponsedRootWindow fromView:nil];
        LayoutDragEvent* event = [LayoutDragEvent eventWithSender:_dragSender location:convertedLocation panel:_draggingPanel];
        processed = [_focusedNode.responser onLayoutDragEndInside:event];
    }
    
    if (processed == NO) {
        //create new window
        LayoutView* view = [_dragSender layoutWillMove];
        if (view != nil) {
            [self.firstResponsedRoot.view.window resetCursorRects];//reset cursorRects before change key window
            [self createNewLayoutWindow:view location:locationInScreen];
        }
    }
    
    if (_dragSender != nil) {
        if ([_dragSender respondsToSelector:@selector(layoutDragDidEnd)]) {
            [_dragSender layoutDragDidEnd];
        }
    }
    _dragSender = nil;
    _focusedNode = nil;
    _dragState = LayoutDragStateUnkown;
    [_draggingPanel close];
}

- (void)cancelDragging
{
    if (_focusedNode != nil) {
        [_focusedNode.responser onLayoutDragOut];
    }
    if (_dragSender != nil) {
        if ([_dragSender respondsToSelector:@selector(layoutDragDidCancel)]) {
            [_dragSender layoutDragDidCancel];
        }
    }
    _dragSender = nil;
    _focusedNode = nil;
    _dragState = LayoutDragStateUnkown;
    [_draggingPanel close];
}

#pragma mark - window delegate
- (void) windowWillClose:(NSNotification *)notification
{
    if (notification.object == _draggingPanel) {
        if (_dragState == LayoutDragStateDraging) {
            [self cancelDragging];
        }
    }
    else {
        for (int i=0; i<_rootList.count; i++) {
            if (notification.object == _rootList[i].view.window) {
                NSMutableArray<LayoutNode*>* nodes = [NSMutableArray arrayWithArray:_rootList[i].virtualNode.subNodes];
                while (nodes.count > 0) {
                    if (nodes[0].subNodes.count > 0) {
                        [nodes addObjectsFromArray:nodes[0].subNodes];
                    }
                    if ([nodes[0] isKindOfClass:[LayoutContentNode class]]) {
                        [_viewMap removeObjectForKey:[NSNumber numberWithUnsignedLong:((LayoutContentNode*)nodes[0]).view.identifier]];//remove relationship from viewmap
                    }
                    [nodes removeObjectAtIndex:0];
                }
                [_rootList removeObjectAtIndex:i];
                break;
            }
        }
    }
}

#pragma mark -
- (LayoutContentNode*)findAssociatedNode:(LayoutView *)view
{
    return [_viewMap objectForKey:[NSNumber numberWithUnsignedLong:view.identifier]];
}

- (LayoutNode*)findeFirstResponsedNode:(NSPoint)location
{
    NSPoint convertedLocation = [self.firstResponsedRoot.view convertPoint:location fromView:nil];
    LayoutNode* node = [self findResponsedNode:convertedLocation node:self.firstResponsedRoot];
    return node!=nil?node:self.firstResponsedRoot;
}

- (LayoutNode*)findResponsedNode:(NSPoint)location node:(LayoutNode *)node
{
    if (NSPointInRect(location, node.frame)) {
        for (int i=0; i<node.subNodes.count; i++) {
            LayoutNode* n = [self findResponsedNode:location node:node.subNodes[i]];
            if (n != nil) {
                return n;
            }
        }
        if (node.responser != nil) {
            return node;
        }
    }
    return nil;
}

@end
